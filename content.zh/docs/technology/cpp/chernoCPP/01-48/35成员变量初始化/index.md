---
title: 35成员变量初始化
description: 35成员变量初始化
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-01-09T23:24:46+08:00
lastmod: 2026-01-09T23:24:46+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 普通的初始化方法

```cpp
#include <iostream>
#include <string>

class Entity
{
private :
	std::string m_Name;
public:
	Entity()
	{
		m_Name = "Unknown";
	}

	Entity(const std::string& name)
	{
		m_Name = name;
	}
	
	const std::string& GetName() const { return m_Name; }
};

int main()
{
	Entity e0;
	std::cout << e0.GetName() << std::endl;
	Entity e1("Cherno");
	std::cout << e1.GetName() << std::endl;
	std::cin.get();
}
```

# 初始化列表

```cpp
#include <iostream>
#include <string>

class Entity
{
private:
	int m_Score;
	std::string m_Name;

public:

	//如果不是用初始化列表，就会先调用成员变量的构造函数初始化给它默认值(这里是m_Name)，然后在{}中再一次赋值
	//如果用了，那就直接使用初始化列表中的值初始化
	//第二种方式只调用了string(const char*)，而第一种方式多调用了一次string()
	Entity()
		:m_Name("Unknown"),m_Score(0) //注意不论这里的书写顺序是啥
		//都是先初始化m_Score，再m_Name
	{

	}

	Entity(const std::string& name)
		: m_Name(name)
	{

	}

	const std::string& GetName() const { return m_Name; }
};

int main()
{
	Entity e0;
	std::cout << e0.GetName() << std::endl;
	Entity e1("Cherno");
	std::cout << e1.GetName() << std::endl;


	std::cin.get();
}
```

## 构造函数的“幕后”过程

> 初始化阶段：以下只针对类对象，基本类型不会被自动初始化（除非是全局变量：全局变量会被清零），它们的值是内存中残留的随机垃圾值。

当你调用一个构造函数时，程序执行并不是直接跳到 { 里的第一行代码，而是经历了两个阶段：  

- 初始化阶段 (Initialization Phase)：按照成员变量在类中声明的顺序，逐个调用它们的构造函数。  
  
  如果你写了“初始化列表”，编译器就按你指定的参数初始化；如果你没写，编译器会尝试调用这些成员的默认构造函数（无参构造函数）。

- 赋值阶段 (Assignment Phase)：此时所有成员已经“诞生”了。  
  
  执行构造函数大括号 { } 里的代码，这通常是执行“赋值”操作。
### 示例-`{}`中初始化

```cpp
#include <iostream>
#include <string>

class Example
{
public:
	Example()
	{
		std::cout << "Created Entity "  << std::endl;

	}
	Example(int x)
	{
		std::cout << "Created Entity with " << x << std::endl;
	}
};

class Entity
{
private: 
	std::string m_Name;
	Example m_Example;

public: 

	Entity() 
	{
		m_Name = std::string("Unknown");
		m_Example = Example(8);
	} 

	const std::string& GetName() const { return m_Name; }
};

int main()
{
	Entity e0; 


	std::cin.get();
}
/*打印
Created Entity
Created Entity with 8
*/
```

### 示例-初始化列表

```cpp
#include <iostream>
#include <string>

class Example
{
public:
	Example()
	{
		std::cout << "Created Entity " << std::endl;

	}
	Example(int x)
	{
		std::cout << "Created Entity with " << x << std::endl;
	}
};

class Entity
{
private:
	std::string m_Name;
	Example m_Example;

public:

	Entity()
		:m_Name("Unkown"),m_Example(8)
	{

	}

	const std::string& GetName() const { return m_Name; }
};

int main()
{
	Entity e0;


	std::cin.get();
}
/*打印 
Created Entity with 8
*/
```