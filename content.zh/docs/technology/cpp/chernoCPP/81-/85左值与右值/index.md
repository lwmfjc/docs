---
title: 85左值与右值
description: 85左值与右值
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-03-06T22:42:42+08:00
lastmod: 2026-03-06T22:42:42+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
#  什么是左值和右值？

- ==核心定义==：Cherno 用最简单的方式解释了两者。    
    - ==左值 (lvalue)== ~~定位值~~ ：有存储地址、有名字的变量。你可以给它赋值，它通常存在于表达式的左侧。
    - ==右值 (rvalue)==：临时值，没有名字，通常在表达式结束后就销毁了（如字面量 `10` 或临时函数返回值）。
- ==直观判定法==：如果你能取这个东西的地址（使用 `&` 运算符），它通常就是左值。

#  左值引用 (lvalue references)

- ==回顾==：这就是我们常用的 `int& a = b;`。
- ==规则限制==：左值引用==不能==绑定到右值上。    
    - `int& a = 10;` 会报错，因为 `10` 是右值。
    - ==例外情况==：`const int& a = 10;` 是合法的。编译器会产生一个临时变量来存放 `10`，然后让引用绑定它。这在函数参数传递中非常常见。
## 例子

```cpp
#ifdef LY_EP85

#include <iostream>   



void SetValueConst(const int& value)
{

}

void SetValue1(int& value)
{

}
void SetValue(int value)
{

}

int GetValue()
{
	return 10;//10是一个右值
}

int& GetRefValue()
{
	static int i=10;
	std::cout << "GetRefValue():" <<  i << std::endl; 
	return i;
}

int main()
{
	int i = 10;//i为左值，10为右值
	//10 = 3;//表达式必须为左值，10是右值，不能作为表达式的左边
	int a = i;//讲一个左值(a)设置为另一个左值(i)
	int i1 = GetValue();//GetValue()是一个右值，i是一个左值
	//GetValue() = 5;//GetValue()是一个右值，不能作为表达式的左边，而表达式必须是一个可修改的左值

	for (int i = 0; i < 3; i++)
	{
		GetRefValue()++;//GetRefValue()是一个左值，可以作为表达式的左边 

	}
	/*
GetRefValue():10
GetRefValue():11
GetRefValue():12
	*/

	SetValue(i);//i是一个左值，可以作为表达式的右边，用左值创建一个临时对象，并将其作为实参传递给函数
	SetValue(10);//10是一个右值，可以作为表达式的右边,即用右值创建一个临时对象，并将其作为实参传递给函数

	SetValue1(i);//从左值创建一个左值引用，所以可以将左值i作为实参传递给函数SetValue1(int& value)，编译器会将i作为实参传递给函数

	//SetValue1(10); //编译出错：不能从右值创建一个左值引用，所以不能将右值10作为实参传递给函数SetValue1(int& value)，编译器会报错 //非const的引用，必须通过左值来初始化

	SetValueConst(i);//从左值创建一个const左值引用 

	SetValueConst(10);//从右值创建一个const左值引用 
	//int& a1 = 10;//非const的引用，必须通过左值来初始化

	//编译器可能创建了一个带实际存储的临时变量(比如temp=10)，然后
	//const int& b1=temp;
	const int& b1 = 11;//const的引用，还可以通过右值来初始化

	std::cin.get();
	return 0;
}
 
#endif
```

#  右值引用 (rvalue references) —— `&&`

- ==新语法==：C++11 引入了 `int&&`。
- ==作用==：它==专门==用来绑定右值。    
    - `int&& a = 10;` 是合法的。
    - 它允许我们“拦截”那些即将销毁的临时对象。
- ==意义何在？==：这是为了==性能优化==。既然右值是临时的，我们与其拷贝它的数据，不如直接“偷”走它的资源（这就是移动语义的基础）。

#  实际应用：函数重载

- ==场景演示==：Cherno 展示了如何通过重载同一函数名，分别处理左值和右值：
  
```cpp
void PrintName(const std::string& name); // 接收左值和 const 右值
void PrintName(std::string&& name);      // 专门接收右值（临时对象）
```

- 解释
	- 如果你传左值 (std::string s)：它能接，因为 const& 兼容左值。
	- 如果你传普通右值 ("Cherno")：它能接，因为 C++ 特许 const& 绑定右值。
	- 如果你传 const 右值：它也能接（这是它最“名副其实”的时候）。
	  
- ==总结==：当你传入一个临时字符串时，编译器会优先调用右值版本。在这个版本里，你可以安全地移动数据而不需要进行昂贵的深拷贝。  

```cpp
#ifdef LY_EP85

#include <iostream>  
#include <string>
 

void PrintName2(std::string&& name)
{
	std::cout << "PrintName2[rvalue:]" << name << std::endl;
}

//const引用，能和右值兼容，既能接受左值，也能接受右值
void PrintName2(const std::string& name)
{
	std::cout << "PrintName2[const lvalue:]" << name << std::endl;
}

void PrintName1(std::string&& name)
{
	std::cout << name << std::endl;
}

void PrintName(std::string& name)
{
	std::cout << name << std::endl;
}

int main()
{ 
	//左值：firstName和lastName是左值，fullName是左值
	//右值：字符串字面值"Yan"和"Chernikov"是右值，firstName + lastName是右值
	// firstName + lastName构建一个临时对象，然后赋值给左值fullName 
	std::string firstName = "Yan";
	std::string lastName = "Chernikov";

	std::string fullName = firstName + lastName; 

	//非const的左值引用只能用左值来初始化，所以也可以用
	//这个函数来测试一个表达式是否是左值
	PrintName(fullName);
	//PrintName(firstName + lastName);//编译报错，非const的左值引用必须用左值来赋值

	//PrintName1(fullName);//编译报错，右值引用不能绑定到左值(必须用右值来赋值)
	PrintName1(firstName + lastName);

	PrintName2(firstName);

	//优先调用void PrintName2(std::string&& name)这个重载版本
	PrintName2(firstName + lastName);

	std::cin.get();
	return 0;
}
#endif
```

==移动语义”（Move Semantics）==。解决一个核心问题：==如何高性能地“掠夺”一个即将销毁的临时对象所拥有的资源，而不是笨重地去复制它。==
 
*性能优化：从“克隆”变为“搬家”*  

- 在没有右值引用之前，如果你想把一个临时字符串传给一个函数并保存下来，系统必须进行==深拷贝（Deep Copy）==：申请新内存 -> 复制每一个字符 -> 销毁原临时字符串。
- 使用 `std::string&&` 后：
	- ==行为==：你可以直接把临时字符串内部指向堆内存的==指针==“偷”过来。
	- ==结果==：只发生了几个字节的指针赋值，没有昂贵的内存分配和字符拷贝。对于巨大的字符串或数组，性能提升是成百上千倍的。



