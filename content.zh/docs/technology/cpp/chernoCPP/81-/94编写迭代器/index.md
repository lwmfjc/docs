---
title: 94编写迭代器
description: 94编写迭代器
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-03-10T12:59:30+08:00
lastmod: 2026-03-10T12:59:30+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
- 迭代器是用来遍历==某种数据结构==的容器的
- 迭代器统一了接口，所以通过同样的接口不同的实现来迭代不同的容器
- 迭代器：记录一个指针，然后遍历就像移动指针一样，直到末尾

# Vector类

为Vector添加部分代码

```cpp
class Vector
{
public:

	//Vector的值类型
	using ValueType = T;
	//public 类型别名 (using/typedef)：属于类（Class/Type）。它是一个“类型标签”，就像 Vector<int> 内部定义的一个子类型。
	using Iterator = VectorIterator<Vector<T>>;

	Iterator begin()
	{
		return Iterator(m_Data);
	}


	Iterator  end()
	{
		return Iterator(m_Data + m_Size);
	}
}
```

Vector类完整代码  

```cpp
#pragma once
#ifdef LY_EP94
#include <memory>
#include <iostream>

//为某种类型(Vector)写迭代器
template<typename Vector>
class VectorIterator
{
public:
	//Vector的值的类型
	using ValueType = typename Vector::ValueType;
	using PointerType = ValueType*;
	using ReferenceType = ValueType&;


	VectorIterator(PointerType ptr)
		:m_Ptr(ptr)
	{

	}

	//前缀运算符
	VectorIterator& operator++()
	{
		m_Ptr++;
		return *this;
	}

	//前缀运算符
	VectorIterator& operator--()
	{
		m_Ptr--;
		return *this;
	}

	//后缀运算符
	//编译器用来区分前缀和后缀的唯一手段，int
	//是语法占位符
	VectorIterator& operator++(int)
	{
		//这里是复制，由于成员只有一个指针，代价可以接受
		VectorIterator iterator = *this;
		//前缀运算符
		++(*this);
		return iterator;
	}

	//后缀运算符
	VectorIterator& operator--(int)
	{
		//这里是复制，由于成员只有一个指针，代价可以接受
		VectorIterator iterator = *this;
		//前缀运算符
		--(*this);
		return iterator;
	}

	ReferenceType operator[](int index)
	{
		return *(m_Ptr + index);
	}

	//C++ 对 -> 有特殊处理。当你使用 it->Method() 时，它会调用 it.operator->() 得到 m_Ptr，然后再次对结果应用 ->。所以最终执行的是 m_Ptr->Method()。
	//所以这里需要返回一个指针
	PointerType operator->()
	{
		return m_Ptr;
	}


	ReferenceType operator*()
	{
		return *m_Ptr;
	}

	bool operator==(const VectorIterator& other) const
	{
		return m_Ptr == other.m_Ptr;
	}
	bool operator!=(const VectorIterator& other) const
	{
		return !(*this == other);
	}

private:
	PointerType m_Ptr;
};

template<typename T>
class Vector
{
public:

	//Vector的值类型
	using ValueType = T;
	//public 类型别名 (using/typedef)：属于类（Class/Type）。它是一个“类型标签”，就像 Vector<int> 内部定义的一个子类型。
	using Iterator = VectorIterator<Vector<T>>;

	Iterator begin()
	{
		return Iterator(m_Data);
	}


	Iterator  end()
	{
		return Iterator(m_Data + m_Size);
	}

public:

	Vector()
	{
		//allocate 2 elements
		ReAlloc(2);
		std::cout << "====构造器中初始化容量2======" << std::endl;
	}

	void PushBack(const T& value)
	{
		//如果当前数量量已经大于等于容量
		if (m_Size >= m_Capacity)
		{
			//如果增长，容量扩大为1.5倍
			ReAlloc(m_Capacity + m_Capacity / 2);
		}

		//m_Data[m_Size] 是一个已经存在的对象，所以
		//这里调用的是拷贝赋值函数
		//m_Data[m_Size] = value;

		// new (&地址) 类型(参数)
		new(&m_Data[m_Size]) T(value);

		m_Size++;
		std::cout << "添加元素:" << value << std::endl;
		std::cout << "==================" << std::endl;
	}

	//1. PushBack的push右值引用的版本
	//2. value 的类型始终是 Vector3&&（右值引用），
	//   但它在函数体内的表现（属性）是一个左值
	void PushBack(T&& value)
	{
		//如果当前数量量已经大于等于容量
		if (m_Size >= m_Capacity)
		{
			//如果增长，容量扩大为1.5倍
			ReAlloc(m_Capacity + m_Capacity / 2);
		}

		//1. m_Data[m_Size] 是一个已经存在的对象，所以
		//这里调用的是移动赋值函数
		//2. value 传入时是右值引用，但在函数内部它有了名
		// 字，就变成了左值。为了触发移动赋值，
		// 必须用 std::move 把它重新转回右值。
		//3. 如果没有移动赋值函数，会去调用拷贝赋值函数
		//m_Data[m_Size] = std::move(value);

		// 使用移动构造函数在原始内存上创建对象
		new(&m_Data[m_Size]) T(std::move(value));

		m_Size++;
		std::cout << "添加元素:" << value << std::endl;
		std::cout << "==================" << std::endl;
	}

	//变长参数模板，三个点 ... 表示它可以接收
	//   任意数量、任意类型的参数
	template<typename... Args>
	//&& 配合模板参数 Args 使用时，不再仅仅是
	//   右值引用，它被称为万能引用，既能接收左值
	//   ，也能接收右值
	T& EmplaceBack(Args&&... args)
	{

		//如果当前数量量已经大于等于容量
		if (m_Size >= m_Capacity)
		{
			//如果增长，容量扩大为1.5倍
			ReAlloc(m_Capacity + m_Capacity / 2);
		}
		//1. 参数一旦有了名字 args，它在函数内部就会变成左值。
		//2. 解决：std::forward 的作用是：如果你传进来时是右值，
		//   它就把它恢复成右值；如果你传进来时是左值，它就保持左
		//   值。
		//3. T(std::forward<Args>(args)...)这个是右值，调用移动
		//   赋值函数后，马上destroy了

		//m_Data[m_Size] = T(std::forward<Args>(args)...); 

		//使用placement new运算符，原地构造，就不会有对临时对象move以及destroy的操作了
		new(&m_Data[m_Size]) T(std::forward<Args>(args)...);

		std::cout << "添加元素:" << m_Data[m_Size] << std::endl;
		std::cout << "==================" << std::endl;

		//1. 取值（Evaluate）：首先取出 m_Size 当前的值（比如现在是 0）。
		//2. 定位（Access）：利用这个旧值 0 找到 m_Data[0] 的引用，作为函数的返回值准备好。
		//3. 自增（Increment）：在这一行语句的逻辑完成，“返回”动作即将发生前（但还在函数体内），将 m_Size 的值加 1 变成 1。
		return m_Data[m_Size++];
	}

	void PopBack()
	{
		if (m_Size > 0)
		{
			m_Size--;
			//手动调用析构函数
			m_Data[m_Size].~T();
		}
	}

	void Clear()
	{
		for (size_t i = 0; i < m_Size; i++)
			m_Data[i].~T();
		m_Size = 0;
	}

	T& operator[](size_t index)
	{
		if (index >= m_Size)
		{
			//assert
		}
		return m_Data[index];
	}

	const T& operator[](size_t index) const
	{
		if (index >= m_Size)
		{
			//assert被设计为一种调试期工具,在发布版本会被去掉
			//assert
		}
		return m_Data[index];
	}

	size_t Size() const { return m_Size; }

	~Vector()
	{
		//会依次调用m_Data指向的所有对象的析构函数（
		// 但是PopBack及Clear()已经调用过并已经释放了
		// Vector3的m_MemoryBlock

		Clear();
		//		delete[] m_Data;

		::operator delete(m_Data, m_Capacity * sizeof(T));

	}
private:
	void ReAlloc(size_t newCapacity) {
		// 1. allocate a new block of memory
		// 2. copy/move old elements into new block
		// 3. delete

		//1. 尽可能低层次的访问内存，而不是智能指针
		//2. 在堆上申请了一块连续(物理连续)的内存空间
		//3. 在堆上创建了 newCapacity 个对象，并调用了它们
		//的默认构造函数。也就是说，此时内存里已经存在了一
		//堆“空”的 Vector3 对象
		//T* newBlock = new T[newCapacity];

		//分配原始字节内存，不调用任何构造函数
		T* newBlock = (T*)::operator new(newCapacity * sizeof(T));

		//如果新容量小于当前大小，即缩小容量
		if (newCapacity < m_Size)
		{
			// 当前大小设置为新容量大小
			m_Size = newCapacity;
			std::cout << "缩小容量--" << std::endl;
		}
		else
		{

			std::cout << "增大容量--" << m_Capacity << "->" << newCapacity << std::endl;
		}

		for (size_t i = 0; i < m_Size; i++)
		{
			//不会触发复制构造函数
			//memcpy(newBlock, m_Data, i * sizeof(T);

			//复制,会触发复制构造函数
			//newBlock[i] = std::move(m_Data[i]);

			// 在 newBlock 的位置上，“构造”一个新对象，其内容移动自旧对象
			new(&newBlock[i]) T(std::move(m_Data[i]));
		}

		//手动释放原来的对象
		for (size_t i = 0; i < m_Size; i++)
		{
			m_Data[i].~T();
		}

		//1. 逐一析构：编译器会根据该内存块记录的大小信息（通常存储在数组头部的隐藏偏移量中），从后往前（或从前往后，取决于实现）调用每一个 Vector3 对象的析构函数。
		//2. 释放内存：在所有对象的析构函数执行完毕后，才会一次性将整块堆内存归还给操作系统。
		//delete[] m_Data;//释放原来指向的内存块

		::operator delete(m_Data, m_Capacity * sizeof(T));

		//delete m_Data;只会触发第一个元素的析构函数

		m_Data = newBlock;//指向新的那个内存块
		m_Capacity = newCapacity;

	}



	T* m_Data = nullptr;
	//实际数组个数
	size_t m_Size = 0;
	//可分配存储的元素个数
	size_t m_Capacity = 0;
};
#endif
```

# Main使用

```cpp
#ifdef LY_EP94

#include <iostream>   
#include <vector>
#include "94_01_vector.h"

int main()
{  
	Vector<int> values;
	values.EmplaceBack(1);
	values.EmplaceBack(2);
	values.EmplaceBack(3);
	values.EmplaceBack(4);
	values.EmplaceBack(5);

	std::cout << "Not using iterators:\n";
	for (int i = 0; i < values.Size(); i++)
	{
		std::cout << values[i] << std::endl;
	}

	std::cout << "Range-based for loop" << std::endl;
	for (int value : values)
	{
		std::cout << value << std::endl;

	}

	std::cout << "Iterator:\n";
	for (Vector<int>::Iterator it = values.begin();
		it != values.end(); it++)
	{
		std::cout << *it << std::endl;
	}

	std::cin.get();
	return 0;
}
#endif;
```

