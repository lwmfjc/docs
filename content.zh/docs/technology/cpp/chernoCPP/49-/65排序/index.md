---
title: 65排序
description: 65排序
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-02-16T23:31:44+08:00
lastmod: 2026-02-16T23:31:44+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
- 数据结构决定了数据的存储方式
- 本节主要讲解如何对现有数据进行排序
- 当使用C++及其内置集合类型,如`std::vector`时,优先用C++内置的函数排序:能根据你==提供的任何迭代器==进行==实际排序== 

# cppreference中的解释

```cpp
//std::sort
//Defined in header <algorithm>
template< class RandomIt >
void sort( RandomIt first, RandomIt last ); (1)(constexpr since C++20)

template< class ExecutionPolicy, class RandomIt >
void sort( ExecutionPolicy&& policy,
           RandomIt first, RandomIt last ); (2)(since C++17)
           
template< class RandomIt, class Compare >
void sort( RandomIt first, RandomIt last, Compare comp ); (3)(constexpr since C++20)

template< class ExecutionPolicy, class RandomIt, class Compare >
void sort( ExecutionPolicy&& policy, RandomIt first, RandomIt last, Compare comp );  (4)(since C++17)
```

可以传入迭代器、谓词（非必须）  

> 迭代器：==存储了原数据的地址==。可以利用迭代器迭代原数据，存储了地址所以可以方便的交换数据

没有返回值，时间复杂度为`O(N·log(N))`

```cpp
Given N as last - first:

1,2) O(N·log(N)) comparisons using operator<(until C++20)std::less{}(since C++20).
3,4) O(N·log(N)) applications of the comparator comp.
```

# 例子

algorithm：`英[ˈælɡərɪðəm]`

```cpp
#ifdef LY_EP65
#include <iostream>
#include <vector>
#include <algorithm>

int main()
{
	std::vector<int> values = { 3,5,1,4,2 };
	//默认是升序排序
	//std::sort(values.begin(), values.end());

	//提供函数，这里是较大值排前面
	//第三个参数：对数组中两个数据调用这个函数后返回 true 
	//代表询问第一个元素应该排在第二个元素之前（吗？这里是肯定），
	//不做处理。返回false 则表示不应该，得交换他们
	//std::sort(values.begin(), values.end(),		std::greater<int>());

	//谓词函数a是否应该排在b之前
	std::sort(values.begin(), values.end(), [](int a, int b)
		{
			//先判断什么情况下是true：b<a时
			//返回true时，a排在b之前
			//推断：b<a时，即a>b时，a排在b之前，所以这里是降序
			//return b < a;

			//a<b的情况下，a在b之前，即升序
			return a < b;
		});

	for (int value : values)
	{
		std::cout << value << std::endl;
	}

	std::cin.get();
}
#endif
```

# 复杂例子

```cpp
#ifdef LY_EP65
#include <iostream>
#include <vector>
#include <algorithm>

int main()
{
	std::vector<int> values = { 3,5,1,4,2 }; 

	//谓词函数询问：a是否应该排在b之前
	std::sort(values.begin(), values.end(), [](int a, int b)
		{ 
			if (a == 1)
			{
				//如果第一个数a是1，那么a不能在前面
				return false;
			}
			if (b == 1)
			{
				//如果第二个数b是1，那么a在前面
				return true;
			}
			//其他情况：如果a<b，那么a排前面
			return a < b;
		});

	for (int value : values)
	{
		std::cout << value << std::endl;
	}

	std::cin.get();
}
#endif
```

# 其他

- 排序的东西不一定要是整数，还可以是字符串或者自定义类