---
title: 42对象生命周期
description: 42对象生命周期
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-01-12T17:33:52+08:00
lastmod: 2026-01-12T17:33:52+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
栈中对象的生命周期  

# 范围

## 栈  

```cpp
#include <iostream>  
#include <string>

class Entity
{
public:

	//constructor-构造函数
	Entity()
	{
		std::cout << "Created Entity!" << std::endl;
	}


	//destructor-析构函数
	~Entity()
	{
		std::cout << "Destroyed Entity!" << std::endl;
	}

};

int main()
{
	std::cout << "start--" << std::endl;
	{
		Entity e;
	}
	std::cout << "end--" << std::endl;
	std::cin.get();
}
/*
start--
Created Entity!
Destroyed Entity!
end--
*/
```

超出范围则自动销毁
## 堆

```cpp
#include <iostream>  
#include <string>

class Entity
{
public:

	//constructor-构造函数
	Entity()
	{
		std::cout << "Created Entity!" << std::endl;
	}


	//destructor-析构函数
	~Entity()
	{
		std::cout << "Destroyed Entity!" << std::endl;
	}

};

int main()
{
	std::cout << "start--" << std::endl;
	{
		Entity* e=new Entity();
	}
	std::cout << "end--" << std::endl;
	std::cin.get();
}
/*
start--
Created Entity!
end--
*/
```

# 返回栈内存的指针及解决办法

```cpp
#include <iostream>  
#include <string>

class Entity
{
public:

	//constructor-构造函数
	Entity()
	{
		std::cout << "Created Entity!" << std::endl;
	}


	//destructor-析构函数
	~Entity()
	{
		std::cout << "Destroyed Entity!" << std::endl;
	}

};

int* CreateArrayWrong()
{
	//在栈上声明一个数组
	//第一个元素为6，剩余49个为0
	int array[50] = { 6 };
	//返回指向该数组(栈内存)的指针
	return array;
}


int* CreateArray1()
{
	//在栈上声明一个数组
	//第一个元素为6，剩余49个为0
	int* array = new int[50] { 6 };
	//返回指向该数组(栈内存)的指针
	return array;
}
void CreateArray2(int*)
{
	//填充数组
}

int main()
{
	//错误,这里得到的数据是不可信的，
	//极有可能被其他代码拿来使用
	int* a = CreateArrayWrong();

	//方法1
	int* a1 = CreateArray1();
	//方法2
	int array[50];
	CreateArray2(array);

	std::cin.get();
}
```

# 智能指针

这是一个包装类，构造在栈中使用指针，分配内存；在包装类销毁时删除指针  

