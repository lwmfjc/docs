---
title: 60(61)命名空间
description: 60(61)命名空间
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-02-11T23:43:16+08:00
lastmod: 2026-02-11T23:43:16+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
- 命名空间是什么、有什么用、何时使用、何时不使用、他们有什么用  
- 主要用途是避免命名冲突

# 60(61)命名空间

```cpp
#include <iostream> 
#include <string>

namespace apple {
	void print(const char* text)
	{
		std::cout << text << std::endl;
	}
}

namespace orange {
	void print(const char* text)
	{
		std::string temp = text;
		std::reverse(temp.begin(), temp.end());
		std::cout << text << std::endl;
	}
}

int main()
{
	//::  这个是作用域解析运算符 
	apple::print("Hello");
	std::cin.get();
}
```

如果这段代码没有命名空间，那么就存在两个函数签名一模一样的函数，编译都过不去 ~~两个同名且相同的符号（类，函数，变量，常量），同一文件中会编译错误，不同文件则链接错误~~   

> C语言没有命名空间语法，所以比如glfw库中的函数都是以glfw开头（避免冲突）  

## 如果没有命名空间  

```cpp
#include <iostream> 
#include <string>

//namespace apple {
	void apple_print(const char* text)
	{
		std::cout << text << std::endl;
	}
//}

//namespace orange {
	void orange_print(const char* text)
	{
		std::string temp = text;
		std::reverse(temp.begin(), temp.end());
		std::cout << text << std::endl;
	}
//}

int main()
{ 
	apple_print("Hello");
	std::cin.get();
}
```

## 代码编写风格

```cpp
namespace apple { namespace functions {
	void print(const char* text)
	{
			std::cout << text << std::endl;
	}
}}
```

这么做仅仅是为了减少缩进  

# 重复引入同名函数

当你写 `using orange::print;` 时，你并不是把 orange 这个空间打开了，而是把 orange 空间里所有名字叫 print 的函数全部“重载”到了当前的作用域（main 函数内部）。  

```cpp
#include <iostream> 
#include <string>

namespace apple {
	void print(const char* text)
	{
		std::cout << text << std::endl;
	}
	void print_again() {}
}

namespace orange {
	void print(const char* text,int x )
	{
		std::string temp = text;
		std::reverse(temp.begin(), temp.end());
		std::cout << text << std::endl;
	}
}

int main()
{ 

	using orange::print; 
	using apple::print;

	//当你写 using orange::print; 时，你并不是把 orange 这个空间打开了，而是把 orange 空间里所有名字叫 print 的函数全部“重载”到了当前的作用域（main 函数内部）。
	print("hello_orange"); 

	std::cin.get();
}
```

1. 编译器在当前作用域找到了两个候选人（一个是 apple 的，一个是 orange 的）。
2. 重载决议启动：编译器发现你只传了一个参数。
3. `orange::print` 需要两个参数，不匹配；而 `apple::print` 完美匹配。
4. 结论：编译器愉快地选择了 `apple::print`，没有任何冲突。

# 别名

使用namespace创建别名  
```cpp
#include <iostream> 
#include <string>

namespace apple {
	namespace functions {
		void print(const char* text)
		{
			std::cout << text << std::endl;
		}
	}
}

namespace orange {
	void print(const char* text )
	{
		std::string temp = text;
		std::reverse(temp.begin(), temp.end());
		std::cout << text << std::endl;
	}
}

int main()
{
	{
		//别名
		namespace a = apple::functions;
		a::print("ha");

		using namespace apple;
		using namespace functions;
		print("c");
	}
	//a::print("ha");//编译报错
	//print("c");//编译报错

	std::cin.get();
}
```

分析一下这块代码  

```cpp
	using namespace apple;
	using namespace functions;
	print("c");
```

- 第一步：`using namespace apple;` 执行完这一行后，apple 空间里的所有内容（包括 functions 这个子命名空间）对 main 函数来说都变成了*==直接可见==*的。
- 第二步：`using namespace functions;` 此时，编译器去寻找 functions。因为你刚刚已经“打开”了 apple，编译器发现：“噢！我知道 functions 是谁，它就在 apple 里面，而且我现在能看到它。”

如果调换这两行，那么连编译都会报错

## 作用域

```cpp
	{
		//别名
		namespace a = apple::functions;
		//....
		//using 指令，不能叫“别名”
		using namespace apple;
		using namespace functions;
	}
```

如上，这些代码块效果仅存在于最小作用域（方括号、函数）里

# 建议

- 不要在头文件中使用 `using nsxxxx::xxs;`  
- 尽量将它限制在更小的作用域内，比如函数、if、文件顶部
- 如果using过度使用，那么就会抵消`命名空间通过避免冲突所做的一切有益工作`
- 为了不干扰 `#include中的文件`,`using语句`、`namespace`语句要放在所有include文件后面
- 其他参考文档  `https://en.cppreference.com/w/cpp/language/namespace.html` 
- c++标准库中的所有内容都在标准命名空间std下
