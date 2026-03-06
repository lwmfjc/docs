---
title: 82单例模式详解
description: 82单例模式详解
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-03-06T13:40:48+08:00
lastmod: 2026-03-06T13:40:48+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
==单例模式 (Singleton)==。单例的核心思想是：==在整个应用程序的生命周期中，某个类只存在一个实例。==

#  什么是单例？ (The Concept)

- ==核心定义==：单例是只有==单一实例==的类。
- ==应用场景==：当你==需要一个全局访问点来管理某些资源==时（如==随机数生成器、渲染器、数据库连接==等）非常有用。
- ==争议性==：单例本质上是“披着类外壳的全局变量”，在某些开发者眼中这被视为一种“反模式”，但 Cherno 认为在特定场景下它非常高效。 ~~把类当做命名空间来调用某些函数~~  
- 如果你只有一个实例，你那实际有的就只是一组数据，以及一些配套功能
- 替代单例：属于某个命名空间的函数、全局变量、某个与源文件关联的静态变量、特定的C++源文件
- 单例的生命周期和应用程序的一样
  
#  基础实现逻辑 (Basic Implementation)

单例模式主要依靠以下三个步骤实现：

1. ==私有化构造函数==：通过 `private` 构造函数防止外部通过 `new` 或直接声明来创建新实例。
2. ==禁用拷贝构造==：删除拷贝构造函数（`ClassName(const ClassName&) = delete;`），确保无法通过复制来产生第二个实例。
3. ==静态访问点==：提供一个静态方法（通常命名为 `Get()`），返回那个唯一的静态实例。

```cpp
#ifdef LY_EP82

#include <iostream>  


class Singleton
{
public:
	Singleton(const Singleton&) = delete;//禁止拷贝
	static Singleton& Get()
	{
		return s_Instance;
	}
	void Function() {
		std::cout << "Function" << std::endl;
	}
private:
	float m_Member = 3.4f;
	Singleton() {}

	static Singleton s_Instance;
};


//定义 
//1. 在全局/静态内存区分配 sizeof(Singleton) 字节的空间。
//2. 在程序启动时，自动调用 Singleton 的构造函数来初始化这块空间。
//由于你使用了作用域解析符 Singleton::，编译器认为这行代码依然属于 Singleton 类的范畴
Singleton Singleton::s_Instance;

int main()
{
	//这种写法，调用了Singleton类的复制构造函数，
	//拷贝了所有成员，并创建了一个新的实例（违背单例本意）
	//类定义中Singleton(const Singleton&) = delete;//禁止拷贝
	//Singleton instance = Singleton::Get();

	auto& instantce = Singleton::Get();
	Singleton::Get().Function();

	std::cin.get();
	return 0;
}
#endif
```

#  现代 C++ 的最佳实践 (The Best Way)

Cherno 演示了最简洁且==线程安全==的单例写法（C++11 及更高版本）：

- ==静态局部变量==：在 `Get()` 函数内部定义一个静态局部变量。
- ==生命周期管理==：该实例在第一次调用 `Get()` 时被初始化，并在程序结束时自动销毁。
- ==代码示例==：

```cpp
    class Singleton {
    public:
        static Singleton& Get() {
            static Singleton instance; // 关键点：静态局部变量
            return instance;
        }
        void Function() {}
    };
```   

#  实例演示：随机数生成器 (Real-world Example)

- Cherno 以一个随机数生成类 `Random` 为例，展示了如何通过 `Random::Get().Float()` 这样简洁的代码在任何地方获取随机数。
- 这样做省去了在每个函数中重复传递 `Random` 对象的麻烦。
## 例子

```cpp
#ifdef LY_EP82

#include <iostream>  


class Random
{
public:
	Random(const Random&) = delete;//禁止拷贝
	static Random& Get()
	{
		return s_Instance;
	}
	static float Float()
	{
		return Get().IFloat();
	}
private:

	float IFloat() {
		return m_RandomGenerator;
	}

	float m_RandomGenerator = 0.5f;
	Random() {}

	static Random s_Instance;
};


//定义 
//1. 在全局/静态内存区分配 sizeof(Singleton) 字节的空间。
//2. 在程序启动时，自动调用 Singleton 的构造函数来初始化这块空间。
//由于你使用了作用域解析符 Singleton::，编译器认为这行代码依然属于 Singleton 类的范畴
Random Random::s_Instance;

int main()
{ 
	//先内联Float变成Random::Get().IFloat();
	//之后内联Get和IFloat变 Random::s_Instance.m_RandomGenerator
	//最后这里还进行常量折叠 float number = 0.5f;
	float number = Random::Float();

	std::cout << number << std::endl;

	std::cin.get();
	return 0;
}
#endif
```

## 把静态声明移到静态函数里

> 仅仅修改了`static Random& Get()`


```cpp
#ifdef LY_EP82

#include <iostream>  


class Random
{
public:

	//禁止拷贝
	Random(const Random&) = delete;

	////禁止赋值
	//赋值运算符：用于更新一个已存在的对象
	/*
	Random r1; // 假设某种情况下你已经有了一个实例（比如在类内部）
	r1 = Random::Get(); // 这会调用赋值运算符
	*/
	Random& operator=(const Random&) = delete;

	static Random& Get()
	{
		//函数里的静态变量，在静态内存中
		//一旦get函数首次被调用，它就会被实例化，然后
		//在后续调用中，它就一直存在于静态内存中
		static Random s_Instance;
		return s_Instance;
	}
	static float Float()
	{
		return Get().IFloat();
	}
private:

	float IFloat() {
		return m_RandomGenerator;
	}

	float m_RandomGenerator = 0.5f;
	Random() {}


};


int main()
{
	//先内联Float变成Random::Get().IFloat();
	//之后内联Get和IFloat变 Random::s_Instance.m_RandomGenerator
	//最后这里还进行常量折叠 float number = 0.5f;
	float number = Random::Float();

	std::cout << number << std::endl;

	std::cin.get();
	return 0;
}
#endif
```

## 使用namespace替换它

```cpp
#ifdef LY_EP82

#include <iostream>  


namespace RandomClass {
	//在 namespace（或全局作用域）中，static 意味着“内部链接（Internal Linkage）”
	static float s_RandomGenerator = 0.5f;
	static float Float() {
		return s_RandomGenerator;
	}
}

int main()
{ 
	float number = RandomClass::Float();

	std::cout << number << std::endl;

	std::cin.get();
	return 0;
}
#endif
```

1. 如果你只是为了全局访问一些数据，不一定非要写一个复杂的类。
2. 这里的 static 和类内部的 static 含义不同，这里意味着内部链接，该变量只在当前.cpp文件可见。如果你把这段代码写在 .h 文件里并被多个 .cpp 包含，每个文件都会拥有一个独立的、互不干扰的 s_RandomGenerator 副本。这在逻辑上就不是真正的“全局唯一”了。  
3. 通常在 .h 里用 extern 声明，在 .cpp 里定义；或者使用 C++17 的 inline static 变量。
### 修复使用方式

```cpp
//Ramdon.h
namespace RandomClass {
    // extern 告诉编译器：这个变量在别处定义了，你先别报错，链接时会找到它。
    extern float s_RandomGenerator; 
    
    float Float();
}
```

```cpp
//Ramdon.cpp
#include "Random.h"

namespace RandomClass {
    // 这里是真正的“地皮”，内存分配发生在这里
    float s_RandomGenerator = 0.5f; 

    float Float() {
        return s_RandomGenerator;
    }
}
```

使用  

```cpp
#include <iostream>
#include "Random.h" // 包含头文件，编译器就知道 RandomClass 是什么了

int main() {
    // 使用 作用域解析符 :: 来访问
    float val = RandomClass::Float();
    std::cout << val << std::endl;

    return 0;
}
```

#  10:01 - 结尾 | 权衡利弊 (Pros & Cons)

- ==优点==：组织清晰，避免了散落在各处的全局变量，方便管理全局状态。
- ==缺点==：增加了代码之间的耦合度，可能使单元测试变得困难，因为单例的状态在测试之间是持久的。