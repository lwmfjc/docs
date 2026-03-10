---
title: 92动态数组实现
description: 92动态数组实现
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-03-09T13:03:14+08:00
lastmod: 2026-03-09T13:03:14+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
涉及到了==手动内存管理==、==堆分配==以及==模板类==的深层逻辑。
#  简要概述

- ==核心目标：实现动态扩容==    
    - 作者明确了本集的目标：创建一个可以根据需要自动增长内存空间的容器，模拟 `std::vector` 的核心行为。
- ==成员变量的改变：从栈到堆==    
    - 不再使用 `T m_Data[S]`，而是改为 `T* m_Data` 指针。
    - 引入两个关键计数器：`m_Size`（当前元素个数）和 `m_Capacity`（当前分配的总空间）。
- ==构造函数与析构函数==    
    - 在构造函数中==预分配一小块初始内存==。
    - 强调了==析构函数==的重要性：必须使用 `delete[] m_Data` 释放堆内存，否则会导致内存泄漏。
- ==实现 `PushBack` 方法（核心逻辑）==    
    - 这是本集最精彩的部分：当 `m_Size >= m_Capacity` 时，触发“==重新分配（Reallocation）==”。
    - ==扩容策略==：作者演示了将容量翻倍（`m_Capacity * 2`）的常用工程策略。
- ==手动执行内存迁移==
    - 详细步骤：申请一块更大的新内存 -> 将旧数据拷贝到新内存 -> 释放旧内存 -> 指针重定向。
- ==模板化的挑战==    
    - 讨论了为什么 Vector 需要模板化，以及在==处理非简单类型（如 `std::string`）时，简单的拷贝可能会失效==（引出对后续移动语义的思考）。
- ==性能测试与优化预告==    
    - 对比了自定义 Vector 与标准库 `std::vector` 的性能。
    - 提到目前的实现虽然可用，但频繁的拷贝开销巨大，引出后续关于 `emplace_back` 的话题。

# 代码`vector.h`

```cpp
//91_01_vector.h
#pragma once
#ifdef LY_EP92
#include <memory>

template<typename T>
class Vector
{
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
		m_Data[m_Size] = value;
		m_Size++;
		std::cout << "添加元素:" << value << std::endl;
		std::cout << "==================" << std::endl;
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
		delete[] m_Data;  
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
		T* newBlock = new T[newCapacity];

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
			newBlock[i] = m_Data[i];
		}

		//1. 逐一析构：编译器会根据该内存块记录的大小信息（通常存储在数组头部的隐藏偏移量中），从后往前（或从前往后，取决于实现）调用每一个 Vector3 对象的析构函数。
		//2. 释放内存：在所有对象的析构函数执行完毕后，才会一次性将整块堆内存归还给操作系统。
		delete[] m_Data;//释放原来指向的内存块

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

## 应用：添加`std::string`元素

```cpp
#ifdef LY_EP92
//在堆上分配内存，创建动态数组
//需要一个指向堆分配内存(数据缓冲区)的指针,随着不断
//添加，当元素越来越多会达到临界点，没有足够空间存储新元素时，
//分配一个新的内存块使它有足够空间容纳这个新元素，将内存块中所有元素
//复制到新内存块，然后删除旧内存块

#include <iostream>   
#include <string>
#include "92_01_vector.h"

template<typename T>
void PrintVector(const Vector<T>& vector)
{
	for (size_t i = 0; i < vector.Size(); i++)
	{
		std::cout << vector[i] << std::endl;
	}

	std::cout << "==================" << std::endl;
}

int main()
{
	Vector<std::string> vector;
	vector.PushBack("Cherno");
	vector.PushBack("C++");
	vector.PushBack("Vector01");
	vector.PushBack("Vector02");
	vector.PushBack("Vector03");
	vector.PushBack("Vector04");
	vector.PushBack("Vector05");
	vector.PushBack("Vector06");
	vector.PushBack("Vector07");

	PrintVector(vector);
	std::cin.get();
	return 0;
}
/*
增大容量--0->2
====构造器中初始化容量2======
添加元素:Cherno
==================
添加元素:C++
==================
增大容量--2->3
添加元素:Vector01
==================
增大容量--3->4
添加元素:Vector02
==================
增大容量--4->6
添加元素:Vector03
==================
添加元素:Vector04
==================
增大容量--6->9
添加元素:Vector05
==================
添加元素:Vector06
==================
添加元素:Vector07
==================
Cherno
C++
Vector01
Vector02
Vector03
Vector04
Vector05
Vector06
Vector07
==================

*/

#endif
```

## 应用添加自定义类元素

```cpp
#ifdef LY_EP92

#include <iostream>   
#include <string>
#include "92_01_vector.h"


struct Vector3
{
	float x = 0.0f, y = 0.0f, z = 0.0f;

	Vector3() {}
	Vector3(float scalar)
		: x(scalar), y(scalar), z(scalar) {
	}
	Vector3(float x, float y, float z)
		: x(x), y(y), z(z) {
	}

	// 拷贝构造函数 (Copy Constructor)
	Vector3(const Vector3& other)
		: x(other.x), y(other.y), z(other.z)
	{
		std::cout << "Copy\n";
	}


	//移动构造函数 (move Constructor)
	Vector3(Vector3&& other)
		: x(other.x), y(other.y), z(other.z)
	{
		std::cout << "Move\n";
	}

	//拷贝赋值
	Vector3& operator=(const Vector3& other)
	{
		std::cout << "copy=\n";
		x = other.x;
		y = other.y;
		z = other.z;
		return *this;
	}

	//移动赋值
	Vector3& operator=(Vector3&& other)
	{
		std::cout << "move=\n";
		x = other.x;
		y = other.y;
		z = other.z;
		return *this;
	}

	~Vector3()
	{
		std::cout << "Destroy\n";
	}
};

//全局重载函数，C++ 规定：对于二元运算符（有两个操作数的运算符），如果写成全局函数，第一个参数对应运算符左边的对象，第二个参数对应右边的对象
std::ostream& operator<<(std::ostream& stream, const Vector3& v)
{
	stream << v.x << ", " << v.y << ", " << v.z;
	return stream;
}

void PrintVector(const Vector<Vector3>& vector)
{
	for (size_t i = 0; i < vector.Size(); i++)
	{
		std::cout << vector[i] << std::endl;
	}

	std::cout << "==================" << std::endl;
}

int main()
{
	Vector<Vector3> vector;

	//Vector3(1.0f)->创建一个匿名临时对象
	//临时对象会在包含它的那个“完整表达式（Full-expression）”结束时被销毁。即这行代码结束后该临时对象被析构
	vector.PushBack(Vector3(1.0f));

	vector.PushBack(Vector3{ 2,3,4 });
	vector.PushBack(Vector3{});


	PrintVector(vector);

	std::cin.get();
	return 0;
}
/*
增大容量--0->2
====构造器中初始化容量2======
copy=
添加元素:1, 1, 1
==================
Destroy
copy=
添加元素:2, 3, 4
==================
Destroy
增大容量--2->3
copy=
copy=
Destroy
Destroy
copy=
添加元素:0, 0, 0
==================
Destroy
1, 1, 1
2, 3, 4
0, 0, 0
==================
*/
#endif
```

如上，每次添加元素，以及扩容时的搬运原元素，都触发了复制赋值函数  

# 修改`vector.h`触发移动赋值函数

```cpp
//92_02_vector.h
#pragma once
#ifdef LY_EP92
#include <memory>

template<typename T>
class Vector
{
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
		m_Data[m_Size] = value;
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
		m_Data[m_Size] = std::move(value);

		m_Size++;
		std::cout << "添加元素:" << value << std::endl;
		std::cout << "==================" << std::endl;
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
		delete[] m_Data;
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
		T* newBlock = new T[newCapacity];

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
			newBlock[i] = std::move(m_Data[i]);
		}

		//1. 逐一析构：编译器会根据该内存块记录的大小信息（通常存储在数组头部的隐藏偏移量中），从后往前（或从前往后，取决于实现）调用每一个 Vector3 对象的析构函数。
		//2. 释放内存：在所有对象的析构函数执行完毕后，才会一次性将整块堆内存归还给操作系统。
		delete[] m_Data;//释放原来指向的内存块

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

## 应用并添加自定义元素

```cpp
#ifdef LY_EP92

#include <iostream>   
#include <string>
#include "92_02_vector.h"


struct Vector3
{
	float x = 0.0f, y = 0.0f, z = 0.0f;

	Vector3() {}
	Vector3(float scalar)
		: x(scalar), y(scalar), z(scalar) {
	}
	Vector3(float x, float y, float z)
		: x(x), y(y), z(z) {
	}

	// 拷贝构造函数 (Copy Constructor)
	Vector3(const Vector3& other)
		: x(other.x), y(other.y), z(other.z)
	{
		std::cout << "Copy\n";
	}


	//移动构造函数 (move Constructor)
	Vector3(Vector3&& other)
		: x(other.x), y(other.y), z(other.z)
	{
		std::cout << "Move\n";
	}

	//拷贝赋值
	Vector3& operator=(const Vector3& other)
	{
		std::cout << "copy=\n";
		x = other.x;
		y = other.y;
		z = other.z;
		return *this;
	}

	//移动赋值
	Vector3& operator=(Vector3&& other)
	{
		std::cout << "move=\n";
		x = other.x;
		y = other.y;
		z = other.z;
		return *this;
	}

	~Vector3()
	{
		std::cout << "Destroy\n";
	}
};

//全局重载函数，C++ 规定：对于二元运算符（有两个操作数的运算符），如果写成全局函数，第一个参数对应运算符左边的对象，第二个参数对应右边的对象
std::ostream& operator<<(std::ostream& stream, const Vector3& v)
{
	stream << v.x << ", " << v.y << ", " << v.z;
	return stream;
}

void PrintVector(const Vector<Vector3>& vector)
{
	for (size_t i = 0; i < vector.Size(); i++)
	{
		std::cout << vector[i] << std::endl;
	}

	std::cout << "==================" << std::endl;
}

int main()
{
	Vector<Vector3> vector;

	//Vector3(1.0f)->创建一个匿名临时对象
	//临时对象会在包含它的那个“完整表达式（Full-expression）”结束时被销毁。即这行代码结束后该临时对象被析构
	vector.PushBack(Vector3(1.0f));

	vector.PushBack(Vector3{ 2,3,4 });
	vector.PushBack(Vector3{});


	PrintVector(vector);

	std::cin.get();
	return 0;
}
/*
增大容量--0->2
====构造器中初始化容量2======
move=
添加元素:1, 1, 1
==================
Destroy
move=
添加元素:2, 3, 4
==================
Destroy
增大容量--2->3
move=
move=
Destroy
Destroy
move=
添加元素:0, 0, 0
==================
Destroy
1, 1, 1
2, 3, 4
0, 0, 0
==================
*/
#endif
```

如上，不论是添加元素还是扩容，都调用的是移动赋值函数  

# 修改`vector.h`就地构造函数

//修改了数组的内存分配方式以及释放内存的方式 ， 涉及到内存分配、释放内存、调用析构函数的地方都进行了修改

```cpp
#pragma once
#ifdef LY_EP92
#include <memory>

template<typename T>
class Vector
{
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

## main函数使用  

```cpp
#ifdef LY_EP92

#include <iostream>   
#include <string>
#include "92_03_vector.h"


struct Vector3
{
	float x = 0.0f, y = 0.0f, z = 0.0f;
	int* m_MemoryBlock=nullptr;

	Vector3() {
		m_MemoryBlock = new int[5];
	}
	Vector3(float scalar)
		: x(scalar), y(scalar), z(scalar) {
		m_MemoryBlock = new int[5];
	}
	Vector3(float x, float y, float z)
		: x(x), y(y), z(z) {
		m_MemoryBlock = new int[5];
	}

	// 拷贝构造函数 (Copy Constructor)
	Vector3(const Vector3& other)
		: x(other.x), y(other.y), z(other.z)
	{
		std::cout << "Copy\n";
	}


	//移动构造函数 (move Constructor)
	Vector3(Vector3&& other)
		: x(other.x), y(other.y), z(other.z)
	{
		m_MemoryBlock = other.m_MemoryBlock;
		other.m_MemoryBlock = nullptr;
		std::cout << "Move\n";
	}

	//拷贝赋值
	Vector3& operator=(const Vector3& other)
	{
		std::cout << "copy=\n";
		x = other.x;
		y = other.y;
		z = other.z;
		return *this;
	}

	//移动赋值
	Vector3& operator=(Vector3&& other)
	{
		m_MemoryBlock = other.m_MemoryBlock;
		other.m_MemoryBlock = nullptr;
		std::cout << "move=\n";
		x = other.x;
		y = other.y;
		z = other.z;
		return *this;
	}

	~Vector3()
	{
		std::cout << "Destroy\n";
		delete m_MemoryBlock;
	}
};

//全局重载函数，C++ 规定：对于二元运算符（有两个操作数的运算符），如果写成全局函数，第一个参数对应运算符左边的对象，第二个参数对应右边的对象
std::ostream& operator<<(std::ostream& stream, const Vector3& v)
{
	stream << v.x << ", " << v.y << ", " << v.z;
	return stream;
}

void PrintVector(const Vector<Vector3>& vector)
{
	for (size_t i = 0; i < vector.Size(); i++)
	{
		std::cout << vector[i] << std::endl;
	}

	std::cout << "==================" << std::endl;
}

int main()
{
	{
		Vector<Vector3> vector;

		//Vector3(1.0f)->创建一个匿名临时对象
		//临时对象会在包含它的那个“完整表达式（Full-expression）”结束时被销毁。即这行代码结束后该临时对象被析构
		vector.EmplaceBack(1.0f);

		vector.EmplaceBack(2, 3, 4);
		vector.EmplaceBack();
		PrintVector(vector);
		vector.PopBack();
		vector.PopBack();
		PrintVector(vector);
		vector.Clear();


		PrintVector(vector);
	}

	{
		std::cout << "**************" << std::endl;
		Vector<Vector3> vector;
		vector.EmplaceBack(1.0f);
		vector.EmplaceBack(2, 3, 4);
		vector.PushBack(Vector3(2.0f));
		PrintVector(vector);
	}

	std::cin.get();
	return 0;
}
/* 使用placement new，省去构造临时对象，move以及destroy
增大容量--0->2
====构造器中初始化容量2======
添加元素:1, 1, 1
==================
添加元素:2, 3, 4
==================
增大容量--2->3
Move
Move
Destroy
Destroy
添加元素:0, 0, 0
==================
1, 1, 1
2, 3, 4
0, 0, 0
==================
Destroy
Destroy
1, 1, 1
==================
Destroy
==================
**************
增大容量--0->2
====构造器中初始化容量2======
添加元素:1, 1, 1
==================
添加元素:2, 3, 4
==================
增大容量--2->3
Move
Move
Destroy
Destroy
Move
添加元素:2, 2, 2
==================
Destroy
1, 1, 1
2, 3, 4
2, 2, 2
==================
Destroy
Destroy
Destroy
*/

/* 如果不是placement new 
增大容量--0->2
====构造器中初始化容量2======
move=
Destroy
添加元素:1, 1, 1
==================
move=
Destroy
添加元素:2, 3, 4
==================
增大容量--2->3
move=
move=
Destroy
Destroy
move=
Destroy
添加元素:0, 0, 0
==================
1, 1, 1
2, 3, 4
0, 0, 0
==================
Destroy
Destroy
1, 1, 1
==================
Destroy
==================
*/
#endif
```