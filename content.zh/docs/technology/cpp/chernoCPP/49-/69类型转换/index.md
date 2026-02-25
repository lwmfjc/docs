---
title: 69类型转换
description: 69类型转换
categories:
  - 学习
tags:
  - cpp
  - cherno
date: 2026-02-24T16:59:48+08:00
lastmod: 2026-02-24T16:59:48+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
- 类型转换（Type Casting）是在 C++ 强类型系统中进行类型间转换的过程。
- cpp作为一种强类型语言，意味着有一个类型系统，且类型是强制规定的
	- 如果一个东西是整型，不能突然把它拿来当双精度数，除非有简单的==隐式转换 ~~意味着cpp知道如何在这两种类型之间转换且不丢失数据~~ ==
	- 可以使用显示转换
- 类型转换包括==C风格转换==和==C++风格转换==

# 基本的显示/隐式转换

```cpp
#ifdef LY_EP69
#include <iostream>

int main()
{
	int a = 5;
	double value = a;//隐式转换

	double value1 = 5.25;
	int a1 = value1;//隐式转换

	int a2 = (int)value1;//显示转换

	std::cout << "a:" << a << std::endl;//5
	std::cout << "value:" << value << std::endl;//5
	std::cout << "value1:" << value1 << std::endl;//5.25
	std::cout << "a1:" << a1 << std::endl;//5
	std::cout << "a2:" << a2 << std::endl;//5


	std::cin.get();
	//成功的情况只有一种（0），而失败的原因
	//可以有成千上万种（1, 2, 3...）。
	return 0;
}
#endif
```


# 类型转换例子

```cpp
#ifdef LY_EP69
#include <iostream>

class Base
{
public:
	Base() {}

	//这里应该把析构函数设为vitual，我只是为了演示
	//只要有虚函数就能用动态转换转换成功，而这个虚函数
	//不一定非得是析构函数
	~Base() {} 

	virtual void test() {}
};

//public Base中 <public> 决定：基类（Base）中的成员在
//派生类（Derived）中保持什么样的访问权限。（public则成员
//的最高权限是public）
class Derived : public Base
{
public:
	Derived() {}
	~Derived() {}
};

class AnotherClass : public Base
{
public:
	AnotherClass() {}
	~AnotherClass() {}
};

int main()
{
	//C风格转换
	double value = 5.25;
	double a1 = value + 5.3;//10.55
	double a2 = (int)value + 5.3;//强制截断，10.3 
	double a3 = (int)(value + 5.3);//强制截断，10 
	std::cout << a1 << std::endl;
	std::cout << a2 << std::endl;
	std::cout << a3 << std::endl;

	// C++风格转换（以下C风格转换都能做到，但是C++风格还会做点
	// 额外的事情）
	double s = static_cast<int>(value) + 5.3;//1 静态转换，会有编译时检查

	//double s1 = static_cast<AnotherClass>(value) + 5.3;//编译失败,没有哪个构造函数支持，即没有 AnotherClass(int)这样的构造函数先隐式转换成AnotherClass

	//AnotherClass s11 = static_cast<AnotherClass*>(value) ;//编译失败，无效的类型转换
	//AnotherClass s12 = static_cast<AnotherClass*>(&value) ;;//编译失败，无效的类型转换


	//2 重新解释转换 //类似类型双关
	AnotherClass* a = reinterpret_cast<AnotherClass*>(&value);//“重新解释转换”，编译通过，即指向该值的指针，解释成：指向另一个类实例的指针


	//3 动态类型转换 //多态时用到
	Derived* derived = new Derived();
	Base* base = derived;
	//检查基类指针是否是(某个)派生类实例 
	//静态转换，但很明显这会出问题(base是指向Derived实例而非AnotherClass)
	AnotherClass* ac1 = static_cast<AnotherClass*>(base);
	AnotherClass* ac1_1 = (AnotherClass*)(base);

	Derived* ac3 = dynamic_cast<Derived*>(base);//编译通过

	AnotherClass* ac2 = dynamic_cast<AnotherClass*>(base);//编译通过，但是返回null
	if (ac3)
	{
		std::cout << "ac3转换成功" << std::endl;//ac3转换成功
	}
	if (ac2)
	{
		std::cout << "ac2转换成功" << std::endl;//没成功
	}

	//4 常量解释转换：移除或添加常量
	//视频没说到

	std::cin.get();
	//成功的情况只有一种（0），而失败的原因
	//可以有成千上万种（1, 2, 3...）。
	return 0;
}
#endif
```

- `dynamic_cast` 是在==运行时（Runtime）==通过查询虚函数表（vtable）来确认对象的实际类型的。 
	- 规则：只有当类中至少包含一个==虚函数（virtual function）==时，编译器才会为该类生成类型信息（RTTI）。
	- 所以如果==被转换==的实例类中完全没有虚函数，那么使用`dynamic_cast`时在编译阶段就报错了
- RTTI (运行时类型识别)：当类包含虚函数时，编译器会==在对象内存布局中增加一个指向“虚函数表”的指针==。表中包含了该类的 `type_info`。
- 安全性检查：执行 `dynamic_cast` 时，程序会检查内存中对象的实际 `type_info`。如果 `Base* base` 实际上指向的是 `Derived`，转换成功；如果指向的是其他不相关的类，则返回 `NULL`。

# 常量转换

```cpp
#ifdef LY_EP69
#include <iostream>

void IncreaseValue(const int* val_ptr) {
	// 编译失败：不能修改 const 指针指向的内容
	//*val_ptr = 10; 

	// 使用 const_cast 去掉 const 属性
	int* modifiable_ptr = const_cast<int*>(val_ptr);
	*modifiable_ptr += 5;
}

int main() {

	//number 是一个普通的非 const 变量 
	int number = 10;

	std::cout << "修改前: " << number << std::endl;

	// 传入 number 的地址
	IncreaseValue(&number);

	std::cout << "修改后: " << number << std::endl; // 输出 15


	//=====演示有问题情况=====
	const int constant_var = 100; // 原始变量就是常量
	const int* ptr = &constant_var;

	int* naughty_ptr = const_cast<int*>(ptr);
	*naughty_ptr = 200; // 危险！这是“未定义行为”
	std::cout << "constant_var修改后: " << constant_var << std::endl;

	// 此时打印 constant_var，结果可能还是 100，也可能是 200，取决于编译器优化

	std::cin.get();
	return 0;
}
#endif
```

为什么number修改成功，而constant_var修改失败

- number 是一个普通的非 const 变量。虽然你在某一时刻给它贴上了 const 的标签（通过指针），但它在内存里的本质依然是可读写的。const_cast 只是恢复了对这块内存的写权限。
- constant_var修改失败
	- 情况 A（编译器的“欺骗”）：编译器在处理 const int 时，会像宏替换一样，把代码里所有出现 constant_var 的地方直接替换成 100。即便你通过指针改了内存里的值，当你直接打印 constant_var 时，它还是显示 100。
	- 情况 B（程序崩溃）：在某些操作系统和编译器下，const 声明的全局变量会被存放在==受硬件保护的只读内存页==。当你尝试写入时，系统会直接触发“段错误”（Segmentation Fault）强制关闭程序。