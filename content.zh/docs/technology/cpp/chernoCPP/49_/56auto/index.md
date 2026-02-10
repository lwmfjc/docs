---
title: 56auto
description: 56auto
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-02-10T16:59:51+08:00
lastmod: 2026-02-10T16:59:51+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
- 让cpp自动推导新声明变量的类型  
- c++在一定程度上会转换为弱类型语言

# 简单例子

```cpp
#include <iostream> 

int main()
{
	auto x = 1;//int
	auto y = 1.0;//double
	int a = 5;
	auto b = a;//int
	auto c = y;//double
	auto d = 3L;//long
	auto e = 5.3f;//float
	auto f = "aa";//const char* //常量字符指针
	std::cout << x << std::endl;
	std::cout << y << std::endl;
	std::cout << a << std::endl;
	std::cout << b << std::endl;
	std::cout << c << std::endl;
	std::cin.get();
}

```

# 进阶例子

```cpp
#include <iostream>
#include <string>

std::string GetName1()
{
	return "Cherno";
}

//返回值应该是const，修改项目设置后才能
// 通过编译: c/c++-Language-Conformancemode-No
char* GetName2()
{
	return "Cherno";
}

int main()
{
	auto a = 'a';

	std::string name1 = GetName1();

	//string有一个可接受字符指针的隐式构造函数
	std::string name2 = GetName2();
	name2.size();

	//如果没有ide显示没办法一眼看出name3的类型
	auto name3 = GetName2(); //char*
	//name3.size();//显然这里编译会失败

	std::cout << *name3 << std::endl;//"C"

	std::cin.get();
}
```
# 补充-接收字符指针如何构造string

```cpp
#include <iostream>
#include <cstring> // 为了使用 strlen 和 strcpy

class SimpleString {
private:
    char* m_Buffer;     // 指向堆内存的指针
    unsigned int m_Size; // 字符串长度

public:
    // 这就是那个“隐式构造函数”
    // 它接收一个 const char* 指针
    SimpleString(const char* string) {
        std::cout << "[Log] 调用了构造函数，接收指针: " << (void*)string << std::endl;
        
        m_Size = strlen(string);          // 1. 计算长度
        m_Buffer = new char[m_Size + 1];  // 2. 在堆上申请内存（+1 是为了放 '\0'）
        memcpy(m_Buffer, string, m_Size + 1); // 3. 将内容从只读区拷贝到堆区
    }

    // 析构函数：防止内存泄漏
    ~SimpleString() {
        delete[] m_Buffer;
    }

    // 辅助函数，方便打印
    void Print() const {
        std::cout << m_Buffer << std::endl;
    }
};

char* GetName2() {
    return (char*)"Cherno"; // 字符串字面量在只读区
}

int main() {
    // 发生了隐式转换！
    // 编译器发现 GetName2() 返回 char*，而你需要 SimpleString
    // 于是它自动调用了 SimpleString("Cherno")
    SimpleString name = GetName2(); 

    name.Print();

    std::cin.get();
}
```


# 相对有用的场景

```cpp
#include <iostream>
#include <string>
#include <vector>

//返回值应该是const，修改项目设置后才能
// 通过编译: c/c++-Language-Conformancemode-No
char* GetName()
{
	return "Cherno";
}

int main()
{
	std::vector<std::string> strings;
	strings.push_back("apple");
	strings.push_back("orange");

	//迭代器，是一个经过精心设计的类，内部最核心的成
	// 员通常就是一个指向容器中某个位置的指针
	for (std::vector<std::string>::iterator it = strings.begin();
		it != strings.end(); it++)
	{
		std::cout << *it << std::endl;
	}

	std::cout << "======1=====" << std::endl;

	//类型过于冗长，用auto替代
	for (auto it = strings.begin();
		it != strings.end(); it++)
	{
		std::cout << *it << std::endl;
	}
	std::cout << "======2=====" << std::endl;

	//类型别名 (Type Aliasing) [现代C++风格]：，支持模板别名（模板化using）
	using UIterator = std::vector<std::string>::iterator;

	//类型别名 (Type Aliasing) [传统C风格]
	typedef std::vector<std::string>::iterator TIterator;

	//类型过于冗长，用auto替代
	for (UIterator it = strings.begin();
		it != strings.end(); it++)
	{
		std::cout << *it << std::endl;
	}
	std::cout << "======3=====" << std::endl;

	//类型过于冗长，用auto替代
	for (TIterator it = strings.begin();
		it != strings.end(); it++)
	{
		std::cout << *it << std::endl;
	}


	std::cin.get();
}
```