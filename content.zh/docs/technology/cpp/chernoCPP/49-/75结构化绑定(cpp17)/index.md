---
title: 75结构化绑定(cpp17)
description: 75结构化绑定(cpp17)
categories:
tags:
date: 2026-03-04T10:29:40+08:00
lastmod: 2026-03-04T10:29:40+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 核心概念

结构化绑定是 ==C++17== 引入的一项新特性，旨在更优雅地处理==多返回值==问题，尤其是处理 `std::pair`、`std::tuple` 或结构体时，能显著==简化代码==并提高可读性。

# 1. 历史演进：在没有结构化绑定之前

在 C++17 之前，处理 `std::tuple` 或 `std::pair` 非常繁琐：

-   ==方法一：使用 `std::get`==    
    - 必须通过索引访问，如 `std::get<0>(person)` 获取姓名，`std::get<1>(person)` 获取年龄。这种方式语义不明确且代码冗长。
-   ==方法二：使用 `std::tie`==
    - 虽然可以解构，但必须==先定义变量==。例如需要先声明 `string name; int age;`，然后再执行 `std::tie(name, age) = createPerson();`。这增加了代码行数，且无法使用 `auto`。

## 代码

```cpp
#ifdef LY_EP75

#include <iostream>  
#include <string>
#include <tuple>

//或者使用std::pair<std::string, int> CreatePerson()
//tuple可以存储任意数量和类型的元素，而pair只能存储两个元素，分别是first和second。
std::tuple<std::string, int> CreatePerson()
{
	return { "Cherno",24 };
}


std::pair<std::string, int> CreatePerson1()
{
	return { "Cherno1",241 };
}

struct Person
{
	std::string name;
	int age;
};

Person CreatePerson2()
{
	return { "Cherno1",241 };
}

int main()
{
	auto person = CreatePerson();
	std::string& name = std::get<0>(person);
	int& age = std::get<1>(person);
	std::cout << "tuple: " << name << " is " << age << " years old." << std::endl;

	auto person1 = CreatePerson1();
	std::string& name1 = person1.first;
	int& age1 = person1.second;
	std::cout << "pair: " << name1 << " is " << age1 << " years old." << std::endl;

	std::string name11;
	int age11;
	std::tie(name11, age11) = CreatePerson();

	std::cout << "tuple with tie: " << name11 << " is " << age11 << " years old." << std::endl;

	std::string name12;
	int age12;
	std::tie(name12, age12) = CreatePerson1(); 

	std::cout << "pair with tie: " << name12 << " is " << age12  << " years old." << std::endl;

	auto person3 = CreatePerson2();
	std::cout << "struct: " << person3.name << " is " << person3.age << " years old." << std::endl;
	std::cin.get();

}
/*
tuple: Cherno is 24 years old.
pair: Cherno1 is 241 years old.
tuple with tie: Cherno is 24 years old.
pair with tie: Cherno1 is 241 years old.
struct: Cherno1 is 241 years old.
*/
#endif
```
# 2. 结构化绑定的基本用法

使用 C++17 的结构化绑定，你可以直接在一行代码中定义并初始化多个变量：

```cpp
auto [name, age] = createPerson(); 
``` 

-   ==简洁性==：不再需要显式定义变量类型，也不需要 `std::get`。
-   ==编译器要求==：必须在项目设置中开启 ==C++17== 标准（如 Visual Studio 中的 `/std:c++17`），否则会报错。
![](img/ly-20260304114304256.png)  

```cpp
#ifdef LY_EP75

#include <iostream>  
#include <string>
#include <tuple>

//或者使用std::pair<std::string, int> CreatePerson()
//tuple可以存储任意数量和类型的元素，而pair只能存储两个元素，分别是first和second。
std::tuple<std::string, int> CreatePerson()
{
	return { "Cherno",24 };
}
 

int main()
{
	auto[name, age] = CreatePerson();
	std::cout << "name:" << name <<   "--age:" <<
		age << std::endl;
	std::cin.get();

}
/*
name:Cherno--age:24
*/
#endif
```
# 3. 实战案例：重构 OpenGL 代码

Cherno 展示了如何将旧代码中的结构体解构，进一步优化代码结构：
-   ==场景==：原本有一个专门用于返回两个着色器源码字符串的 `struct ShaderProgramSource`。
## 旧代码

```cpp
//结构体定义
struct ShaderProgramSource
{
    std::string VertexSource;
    std::string FragmentSource;
};

//函数声明
ShaderProgramSource ParseShader(const std::string& filepath);
```

## 修改

- ==优化==：删除结构体定义，修改ParseShader返回值，将其改为返回 `std::tuple<string, string>`。
  
  ```cpp
  std::tuple<string, string> ParseShader(const std::string& filepath);
  ```
  
- ==调用端==：
  
```cpp
   auto [vertexSource, fragmentSource] = ParseShader("Basic.shader");
```
   
-   ==好处==：减少了代码库中“只用一次”的结构体类型定义，使代码库更加干净、不臃肿。

# 4. 使用建议

-   如果一个数据结构在代码库中被==频繁使用==，保留明确命名的 `struct` 依然是更好的选择。
-   如果只是为了==函数返回多个值==，且这些值在调用后立即被解构使用，那么使用 `tuple` 加==结构化绑定==是目前最优雅、最高效的做法。



