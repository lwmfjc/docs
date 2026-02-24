---
title: 68虚析构函数
description: 68虚析构函数
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-02-23T08:51:18+08:00
lastmod: 2026-02-23T08:51:18+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
- 虚析构函数对处理多态性而言非常重要
- 如果类B从类A派生而来，`A a=new B()`，现在如果决定detele a ，此时希望运行的不仅是A的析构函数，还有B的析构函数。这本质上就是虚析构函数的作用

# 虚函数的核心作用与机制

在 C++ 中，==虚函数（Virtual Function）== 是实现==多态性（Polymorphism）的核心机制==。它允许程序在运行期间（Runtime）根据对象的实际类型来调用相应的函数，而不是在编译期间（Compile time）就固定死。
## 1. 实现动态绑定 (Dynamic Binding)

这是虚函数最直接的作用。在基类指针或引用指向派生类对象时，调用虚函数会执行“子类版本”而非“基类版本”。

* ==非虚函数：== 编译器根据指针的==类型==决定调用哪个函数（静态绑定）。
* ==虚函数：== 编译器根据指针指向的==实际对象==决定调用哪个函数（动态绑定）。
## 2. 支持接口复用与扩展 (Extensibility)

通过虚函数，你可以编写通用的代码来处理不同类型的对象，而无需知道它们的具体类别。

| 特性                | 说明                         |
| ----------------- | -------------------------- |
| ==一致性==           | 基类定义接口规范，所有子类必须遵循。         |
| ==可扩展性==          | 增加新的子类时，不需要修改原有的基类或调用方的逻辑。 |
| ==重写 (Override)== | 子类可以根据自身需求，重新定义基类的行为。      |
## 3. 虚析构函数的重要性 (Virtual Destructor)

在多态场景下，==基类的析构函数必须声明为 `virtual`==。

* ==原因：== 如果基类析构函数不是虚函数，当删除一个指向派生类对象的基类指针时，只会调用基类的析构函数，导致派生类特有的成员变量无法被正确释放，从而产生==内存泄漏 (Memory Leak)==。
## 4. 底层实现：虚函数表 (Vtable)

虚函数是通过 ==虚函数表 (Virtual Table, vtbl)== 和 ==虚函数表指针 (vptr)== 实现的：

1. ==vptr：== 每个含有虚函数的对象内部都有一个隐藏指针。
2. ==vtbl：== 存储了该类所有虚函数的地址。
3. ==调用过程：== 程序运行阶段，通过对象的 `vptr` 找到 `vtbl`，再从中找到对应的函数地址。这虽然比普通函数调用稍微多了一点点开销，但换取了极大的灵活性。
## 简短代码示例

```cpp
class Animal {
public:
    virtual void speak() { cout << "Animal speaks"; } // 虚函数
    virtual ~Animal() {} // 虚析构函数
};

class Dog : public Animal {
public:
    void speak() override { cout << "Woof!"; } // 重写
};

void makeItSpeak(Animal* a) {
    a->speak(); // 运行阶段根据 a 指向的具体对象决定调用哪个 speak()
}

```

# 类继承时构造与析构的顺序
```cpp
#ifdef LY_EP68
#include <iostream>

class Base
{
public:
	Base() { std::cout << "Base constructor\n"; }
	~Base() { std::cout << "Base destructor\n"; }
};

class Derived : public Base
{
public:
	Derived() { std::cout << "Derived constructor\n"; }
	~Derived() { std::cout << "Derived destructor\n"; }
};

int main()
{
	Base* base = new Base();
	delete base;
	std::cout << "------------------\n";
	Derived* derived = new Derived();
	delete derived;
	std::cout << "------------------\n";
	Base* poly = new Derived();
	delete poly;

	std::cin.get();
}
#endif
/*输出
Base constructor
Base destructor
------------------
Base constructor
Base destructor
------------------
Base constructor
Derived constructor
Derived destructor
Base destructor
------------------
Base constructor
Derived constructor
====================> 输出没有这行：Derived destructor，没有调用子类析构函数，即内存泄露，没有释放m_array
Base destructor
*/
```


第一部分：new Base()
这是最基础的情况：

- 构造：调用 Base 的构造函数。
- 析构：delete 时调用 Base 的析构函数。

第二部分：new Derived()（核心重点）
当你创建一个子类（Derived）对象时，内存中其实是“套娃”结构：子类包裹着父类。

- 构造顺序（由内而外）：
	- Base constructor：必须==先初始化父类==，因为子类可能依赖父类的成员。
	- Derived constructor：==父类准备好后，才执行子类==自己的初始化逻辑。

- 析构顺序（由外而内）：
	- Derived destructor：==先拆掉子类特有的==部分。
	- Base destructor：==最后拆掉父类==部分。

生活化比喻：
构造就像盖楼，必须先打地基（Base），再盖楼层（Derived）；
析构就像拆楼，必须先拆楼层（Derived），最后才能拆地基（Base）。

# 虚析构函数

- 如果将基类的析构函数，设为虚函数，实际上会调用两者，会先调用派生类的析构函数，然后再向上调用继承体系中的析构函数（基类的析构函数）  
- 主要跟`虚函数/虚函数表`有关，详见 [26-29继承_虚函数_接口_可见性](../../01-48/26-29继承_虚函数_接口_可见性/index.md)
- 以下代码仅添加了virtual

```cpp
#ifdef LY_EP68
#include <iostream>

class Base
{
public:
	Base() { std::cout << "Base constructor\n"; }
	
	//析构函数加virtual，表示这个类可能被拓展（继承），可能会有一个析构函数
	//需要被调用
	virtual ~Base()  { std::cout << "Base destructor\n"; }
};

class Derived : public Base
{
public:
	Derived() { m_array = new int[5];  std::cout << "Derived constructor\n"; }
	~Derived() { delete[] m_array; std::cout << "Derived destructor\n"; }
private:
	int* m_array;
};

int main()
{
	Base* base = new Base();
	delete base;
	std::cout << "------------------\n";
	Derived* derived = new Derived();
	delete derived;
	std::cout << "------------------\n";
	Base* poly = new Derived();
	delete poly;

	std::cin.get();
}
#endif

/*
Base constructor
Base destructor
------------------
Base constructor
Derived constructor
Derived destructor
Base destructor
------------------
Base constructor
Derived constructor
Derived destructor
Base destructor
*/
```

