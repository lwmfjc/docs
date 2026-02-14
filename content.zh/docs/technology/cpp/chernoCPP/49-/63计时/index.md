---
title: 63计时
description: 63计时
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-02-12T19:39:48+08:00
lastmod: 2026-02-12T19:39:48+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
- 计时：完成某项操作或执行特定代码所需的时间  
- c++17加入了 chrono

# 计时简单例子

```cpp
#ifdef LY_EP63

#include <iostream> 
//引入了本节所需要的大部分内容
//跨平台计时
#include <chrono>
//线程相关
#include <thread>

int main()
{
	//为了使用1s表示1秒的用法
	using namespace std::literals::chrono_literals;

	//获取当前时间
	//auto--> std::chrono::steady_clock::time_point
	auto start = std::chrono::high_resolution_clock::now();

	//模拟耗时
	//指定大概睡眠1秒，会有其他开销
	std::this_thread::sleep_for(1s);
	auto end = std::chrono::high_resolution_clock::now();
	
	//算出实际时长
	//也可以用auto
	std::chrono::duration<float> duration = end - start;
	std::cout << duration.count() << "s" << std::endl;
	
	std::cin.get();
}
#endif 
```

## 解释字面量`1s`

`1s` 被称为 ==用户定义字面量 (User-defined literals)==，代表一个 `std::chrono::seconds` 对象，其值为 1。字面量本质上是调用了一个特殊的运算符函数

```cpp
// 编译器实际执行的操作（示意）
operator""s(1);
```

在c++的标准库的头文件中，它的定义大致如下：  

```cpp
// 简化后的底层实现
constexpr chrono::seconds operator""s(unsigned long long _Val) noexcept {
    return chrono::seconds(_Val);
}
```

- ==operator""：这是定义字面量的关键字==。
- s：这是后缀名称。
- constexpr：意味着这个转换在编译期就能完成，没有任何运行时开销（Runtime overhead）。
# 给函数计时

```cpp
#ifdef LY_EP63

#include <iostream> 
//引入了本节所需要的大部分内容
//跨平台计时
#include <chrono>
//线程相关
#include <thread>

struct Timer
{
	std::chrono::time_point<std::chrono::steady_clock> start, end;
	std::chrono::duration<float> duration;


	Timer()
	{
		start = std::chrono::high_resolution_clock::now();
	}

	~Timer()
	{
		end = std::chrono::high_resolution_clock::now();
		duration = end - start;//可以省略不存储结束值

		//1000.0f不是重载，而是编译器硬编码的，1000f会编译报错
		float ms = duration.count() * 1000.0f;
		//24ms
		//std::cout << "Timer took " << ms << "ms" << std:: endl;
		//21ms
		std::cout << "Timer took " << ms << "ms\n";// << std::endl;
	}
};

void Function()
{
	//作用域(函数)内创建Timer对象,整个(函数)作用域(结束后)都会被计时
	Timer timer;
	for (int i = 0; i < 100; i++)
		std::cout << "Hello" << std::endl;
}

int main()
{ 
	Function();
	std::cin.get();
}
#endif 
```

# 其他

- visual studio也自带分析工具
- 或者其他任何集成开发环境也许自带分析工具
- 可以在源代码中修改使其具有类似的计时(分析)工具
- 还可以用来展示每个函数运行时长的图表,以及那个函数调用了哪个函数