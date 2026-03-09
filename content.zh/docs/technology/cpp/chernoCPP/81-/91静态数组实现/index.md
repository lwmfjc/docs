---
title: 91静态数组实现
description: 91静态数组实现
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-03-08T23:11:54+08:00
lastmod: 2026-03-08T23:11:54+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
- ==为什么要手写数据结构？==
    - 作者解释说，虽然 `std::array` 很好用，但作为底层程序员，你应该了解它在==堆栈（Stack）==上是如何分配内存的。这有助于你==理解内存布局和模板编程==。
- ==模板类（Template Class）的声明==
    - 开始编写 `Array<T, S>`。
    - ==重点==：这里的 `T` 是元素类型，`S` 是==编译期常量==（数组大小）。作者解释了为什么在 C++ 中==通过模板传递数组大小比通过构造函数传递更高效（因为它在编译时就确定了内存空间）==。
- ==内存分配的核心：原始数组==
    - 在类内部定义 `T m_Data[S]`。
    - ==关键点==：这证明了 `Array` 是分配在==栈==上的，其生命周期由作用域决定。
- ==实现 `Size()` 方法==
    - 定义一个简单的 `constexpr size_t Size() const { return S; }`。
    - 强调了 `constexpr` 的作用，让这个大小在编译阶段就能被其他代码使用。
- ==运算符重载：实现 `operator[]`==
    - 为了像使用普通数组一样使用它（例如 `data[0]`），作者演示了如何编写两个版本的下标运算符：
        1.  ==普通版本==：`T& operator[](size_t index)`。
        2.  ==Const 版本==：`const T& operator[](size_t index) const`（为了处理 `const Array` 对象）。
- ==内存布局验证==
    - 作者通过调试器（Debugger）展示了 `Array` 在内存中的连续排布情况。
- ==总结与后续预告==
    - 这集完成了一个==静态的由栈分配的数组== ~~连续存储一定数量数据元素~~ 。作者提到，下一集（92 集）将在此基础上引入==堆（Heap）内存分配==，实现动态扩容的 `Vector`。

*用C++编写一个固定大小，基于栈分配的数组数据结构*  

# 91静态数组实现
## 栈分配和堆分配

```cpp
#ifdef LY_EP91

#include <iostream>   
#include <array>

int main()
{
	int k = 3;
	const int const_k = 5; //常量表达式，编译时可确定

	//栈分配
	//int myarray[k];//编译出错
	//const_k必须是编译时已知的常量
	int myarray[const_k];
	for(int i=0;i<const_k;i++)
	{ 
		//未初始化，值为栈上的垃圾值
		std::cout << myarray[i] << std::endl;
	}
	//myarray在栈帧弹出时自动释放


	//堆分配，且用指针寻址
	//动态分配，大小无需在编译时确定
	int* heapArray = new int[k];

	delete[] heapArray; //释放堆内存

	//c++11提供的标准数组，大小必须在编译时确定
	//这是个模板类，通过模板指定类型和大小
	// _EXPORT_STD template <class _Ty, size_t _Size>
	std::array<int, 5> collection;

	collection.size();//成员函数，返回数组大小

	for (int i = 0; i < collection.size(); i++)
	{
		std::cout << collection[i] << std::endl;
	}

	//要让 for (int i : collection) 运行，C++ 编译器会寻找两个特定的函数：begin() 和 end()。
	for (int i : collection)
	{

	}

	std::cin.get();
	return 0;
} 
#endif
```

## 使用alloca函数在栈上分配内存

```cpp
#ifdef LY_EP91

#include <iostream>   

class Array
{
public:
	Array(int size)
	{
		//alloca函数在栈上分配内存，分配的内存在当前函数返回时自动释放
		m_Data = (int*)alloca(size * sizeof(int));
	}
private:
	int* m_Data;
};

int main()
{
	int size = 5;
	Array arr(size);


	std::cin.get();
	return 0;
}

#endif
```

## 代码示例

```cpp
#ifdef LY_EP91

#include <iostream>   

//size_t 的使命是“能够表示内存中最大的对象”，
//在几位的机器上运行就是几位大小
template<typename T, size_t S>
class Array
{
public:

	//编译期常量
	constexpr size_t Size() const
	{
		return S;
	}

	//这样会导致取出数组元素后会被复制，且也无法修改
	//T operator[] (int index)

	//返回引用，是能修改的左值
	//1. 普通版本：允许读写
	T& operator[] (size_t index)
	{
		return m_Data[index];
	}


	//2：只允许读,而且返回const引用
	//通过这个返回的普通引用，别人依然可以修改 m_Data 里的内容，这违背了函数末尾 const 的初衷
	 //T& operator[] (int index) const

	//2：只允许读,而且返回const引用
	//取决于你调用该函数的对象本身是否是 const,是const
	//对象则调用该重载版本
	const T& operator[] (size_t index) const
	{
		return m_Data[index];
	}

	T* Data()
	{
		return m_Data;
	}

	//常量版本
	const T* Data() const
	{
		return m_Data;
	}

private:
	T m_Data[S];
};

int main()
{
	//每次创建新类，编译器都会根据模板参数生成一个新的类
	Array<int, 5> data;


	//每个字节都是 1
	memset(&data, 1, data.Size() * sizeof(int));

	//每个字节都是 2
	memset(data.Data(), 2, data.Size() * sizeof(int));

	//把数组中每个字节设为0
	memset(&data[0], 0, data.Size() * sizeof(int));

	//编译期的断言检查。让编译器在把代码编译成程序之前，先检查一下你的逻辑对不对，如果条件不满足，编译器会直接报错并拒绝生成程序 
	static_assert(data.Size() < 10, "Size is too large!");

	//因为data.Size()是编译期常量
	Array<std::string, data.Size()> a;

	//
	const auto& arrayReference = data;

	//arrayReference[2] = 3; //

	//arrayReference是const修饰的，编译器只能调用带有 const 后缀的版本
	std::cout << arrayReference[2] << std::endl;

	for (size_t i = 0; i < data.Size(); i++)
	{
		//data[i] = i;
		std::cout << data[i] << std::endl;
	}

	Array<std::string, 3> data1;
	data1[0] = "hello";
	data1[1] = "world";
	for (size_t i = 0; i < data1.Size(); i++)
	{
		//data[i] = i;
		std::cout << data1[i] << std::endl;
	}

	std::cin.get();
	return 0;
}
/*
0
0
0
0
0
0
hello
world

*/
#endif
```

