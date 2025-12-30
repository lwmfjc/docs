---
title: 面向对象
description: 面向对象
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2025-12-30T14:45:25+08:00
lastmod: 2025-12-30T14:45:25+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 编写一个类

```cpp
#include <iostream>

class Log
{
public:
	const int LogLevelError = 0;
	const int LogLevelWarning = 1;
	const int LogLevelInfo = 2;
private:
	//日志实际级别
	//m开头表示类成员变量
	int m_LogLevel = LogLevelInfo;
public:
	void SetLevel(int level)
	{
		m_LogLevel = level;
	}

	//关于字符串指针，后面会讲解
	void Error(const char* message)
	{
		if (m_LogLevel >= LogLevelError)
			std::cout << "[ERROR]:" << message << std::endl;
	}

	void Warn(const char* message)
	{
		if (m_LogLevel >= LogLevelWarning)
			std::cout << "[WARNING]:" << message << std::endl;
	}

	void Info(const char* message)
	{
		if (m_LogLevel >= LogLevelInfo)
			std::cout << "[INFO]:" << message << std::endl;
	}
};

int main()
{
	Log log;
	//警告或更严重的消息会被打印出
	log.SetLevel(log.LogLevelWarning);
	log.Warn("Hello!");
	log.Error("Hello!");
	log.Info("Hello!");
	/*
	[WARNING]:Hello!
	[ERROR]:Hello!
	*/

	std::cin.get();
}
```

# 静态_static

使用场景：类/结构体内部；类/结构体外部  
- 类/结构体的静态意味着该符号(变量/函数名)的链接将是内部含义，只有该翻译单元能看到
- 类/结构体中的静态变量，实际上将与类的所有实例共享内存（该静态变量的内存），类的静态方法也是一样
# static_类外部的

```cpp
//Static.cpp
//这个变量只会在翻译单元(文件)内部被链接
//链接器不会在这个翻译单元的范围之外查找该符号定义,即其他翻译单元看不到它
//如果去掉static关键字，则会报错
//1>Static.obj : error LNK2005: "int s_Variable" (?s_Variable@@3HA) already defined in Main.obj
static int s_Variable = 5;

```

```cpp
//Main.cpp
#include <iostream>

int s_Variable = 10;

int main()
{
	std::cout << s_Variable << std::endl;
	std::cin.get();
}
```

## 去掉关键字static

```cpp
//Static.cpp
//这里如果加上static(配合Main.cpp中的extern)，则会提示1>Main.obj : error LNK2001: unresolved external symbol "int s_Variable" (?s_Variable@@3HA)

int s_Variable = 5;

```

```cpp
//Main.cpp

#include <iostream>

//extern：表示这个变量在其他地方（可能是其他源文件）已经定义
extern int s_Variable ;

int main()
{
	std::cout << s_Variable << std::endl;
	std::cin.get();
}
```

如果你想在两个不同的文件中包含同一个头文件，那么该头文件中的变量得是静态变量。  

# static_类内部或结构内部

如果一个类变量是静态的，意味着他在所有实例中拥有同一份实例  

```cpp
#include <iostream>

struct Entity
{
	//x,y默认是public，如果是private则无法在外部设置值
	static int x, y;
	void Print()
	{
		std::cout << x << "," << y << std::endl;
	}
};

//必须在外部定义，否则提示1>Main.obj : error LNK2001: unresolved external symbol "public: static int Entity::x" (?x@Entity@@2HA)
//在 C++ 中，静态成员变量：
//在类内只是声明，告诉编译器这个静态变量存在
//必须在类外单独定义（分配存储空间）
int Entity::x;
int Entity::y;

int main()
{
	Entity e;
	e.x = 2;
	e.y = 3;

	//如果x.y是static则不能这样初始化
	//Entity e1 = { 5,8 };
	Entity e1;
	e1.x = 5;
	e1.y = 8;

	e.Print();
	e1.Print();
	/*
	5,8
	5,8
	*/
	std::cin.get();
}
```

其中静态变量的设置：`e1.x = 5;e1.y = 8;`，也可以使用`Entity::x = 5;Entity::y = 8;`替代  

类静态成员的意义：你有一块信息，希望在所有实体之间共享。  

## 静态方法

```cpp
#include <iostream>

struct Entity
{
	static int x, y;
	static int x, y;
	static void Print()
	{
		//静态方法无法访问非静态成员变量，因为他
		//不知道访问的是哪个实例的成员变量
		//否则提示C++ a nonstatic member reference must be relative to a specific object
		std::cout << x << "," << y << std::endl;
	}
};

int Entity::x;
int Entity::y;

int main()
{
	Entity::x = 2;
	Entity::y = 3;

	Entity::x = 5;
	Entity::y = 8;

	Entity::Print();
	Entity::Print();
	/*
	5,8
	5,8
	*/

	std::cin.get();
}
```

