---
title: 77在单变量中存储多种类型数据
description: 77在单变量中存储多种类型数据
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-03-04T19:48:33+08:00
lastmod: 2026-03-04T19:48:33+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 核心概念

本集介绍了 ==C++17== 引入的 `std::variant`。它是一个==类型安全的联合体 (Type-safe Union)==，允许==一个变量在不同时间存储预定义的一组类型中的任意一种== ~~比如我接收一个参数可能是字符串或者整数--因为也许我接受的参数来自命令行参数~~ 。 

# 1\. 为什么需要 std::variant？ 

在 C++17 之前，如果你想让一个变量既能存 `string` 也能存 `int`：

- ==使用 `union`==：传统的 `union` 不够安全，它不会追踪当前存储的是哪种类型，且处理复杂类型（如 `std::string`）时非常麻烦。 
- ==使用 `std::variant`==：它解决了这些问题。它知道自己当前存的是什么，并且会自动处理复杂类型的构造和析构。 

# 2\. 基本用法 

- ==包含头文件==：`#include <variant>`
- ==声明与赋值==：
```cpp
	//列出可能的数据类型
    std::variant<std::string, int> data; 
    data = "Cherno"; // 存储 string
    data = 24;       // 存储 int
```

- ==注意==：`variant` 的大小等于其最大候选类型的大小加上一些存储索引的开销（类似于 `struct`），这与 `union` 共享内存的特性类似。 

# 3\. 如何读取数据 

由于 `variant` 是类型安全的，你不能直接访问，有几种主要方式：

- ==`std::get<T>(var)`==：指定类型获取。如果类型不匹配，会抛出 `std::bad_variant_access` 异常。 
- ==`std::get_if<T>(&var)`==：==（推荐方式）== 传入地址。如果类型匹配则返回指针，否则返回 `nullptr`。这种方式不会抛出异常，适合配合 `if` 使用。 
- ==`std::variant::index()`==：返回当前存储类型的索引（从 0 开始）。 

## 例子

```cpp
#ifdef LY_EP77

#include <iostream>
#include <variant>

int main()
{
	std::variant<std::string, int> data;
	data = "Cherno";
	std::cout << std::get<std::string>(data) << std::endl;
	data = 2;
	//data = 3.45;//编译报错，不通过
	std::cout << std::get<int>(data) << std::endl;
	//std::cout << std::get<std::string>(data) << std::endl;//运行时抛出异常
	data = true;//隐式转换，true转为1
	std::cout << std::get<int>(data) << std::endl;//1

	//运行时抛出异常
	//Unhandled exception at 0x763A2CA4 in HelloWorld62.exe: Microsoft C++ exception: std::bad_variant_access at memory location 0x012FFA2C.
	//std::cout << std::get<std::string>(data) << std::endl;

	//如上定义该变量时,std::string对应的索引映射为0，int对应的索引映射为1
	std::cout << data.index() << std::endl;

	//get_if函数接受一个地址，返回一个指针
	//如果当前 variant 存的数据类型匹配，它返回指向该数据的指针。
	//如果类型不匹配，它返回 nullptr（空指针），而不会让程序崩溃。
	if (auto  value = std::get_if<std::string>(&data))
	{
		std::string& v = *value;
		std::cout << "it's a string:" << v << std::endl;
	}
	else if (auto  value = std::get_if<int>(&data))
	{
		int& v = *value;
		std::cout << "it's an int:" << v << std::endl;

	}

	//union 的特点是所有成员共享同一块内存。如果你给 age 赋值，就会覆盖掉 name 的内存。如果此时 name 原本存有字符串，它的析构函数将无法正确释放内存，导致内存泄漏或崩溃。
	//注意：在现代 C++ 中，如果你要在 union 里放 std::string，你必须手动定义 union 的构造和析构函数。
	union TestS
	{
		std::string name;//28字节
		int age;//4字节
	};
	std::cout << "union======size===" << std::endl;
	std::cout << sizeof(std::string) << std::endl;//28字节
	std::cout << sizeof(int) << std::endl;//4字节
	std::cout << sizeof(TestS) << std::endl;//28字节
	std::cout << "variant======size===" << std::endl;

	//32=28+4，所以基本上创建了struct，或者说用于存储两种数据类型的空间；所以union更高效，而variant安全性更高
	std::cout << sizeof(data) << std::endl;//32


	std::cin.get();
	return 0;
}
#endif
#endif
```

### `data = false;`分析

当执行 `data = false;` 时，发生了==隐式类型转换（Implicit Conversion）==。

1.  ==匹配类型==：`std::variant<std::string, int>` 中并没有 `bool` 类型。
2.  ==寻找最佳匹配==：编译器会查看 `false` 是否可以转换成 `std::string` 或 `int`。
    -   `false` 无法隐式转换为 `std::string`。
    -   `false` 可以完美地隐式转换为 `int`（`false` 变为 `0`，`true` 变为 `1`）。
3.  ==重新赋值==：编译器决定将 `false` 转换为 `int(0)`，并将其存储在 `variant` 中。
4.  ==状态更新==：此时 `variant` 的内部索引（index）会更新为 `1`（对应 `int` 的位置），之前存储的 `"Cherno"` 或其他值会被销毁。

所以当你执行 `std::get<int>(data)` 时，它会输出 `0`。

### 为什么variant更安全

`std::cout << sizeof(data) << std::endl;`  输出32  

#### 1\. 它拥有“类型标签”（Type Index）

在 `union` 中，内存是“盲目”的。你存入了一个 `string`，但你可以随时用 `int` 的方式去读取它，编译器不会阻止你，结果只会是一堆乱码甚至导致程序崩溃。

而 `std::variant` 在内部维护了一个==索引（Index）==：

-   当你执行 `data = "Cherno"` 时，Index 设为 `0`。
-   当你执行 `data = 2` 时，Index 设为 `1`。

当你尝试读取时，它会先检查这个 Index。如果你存的是 `int`（Index 1）却尝试用 `std::get<string>`（Index 0）去读，它会==抛出异常==或==返回空指针==，而不是任由错误发生。

#### 2\. 自动管理生命周期（最核心的区别）

这是 `union` 最大的痛点。像 `std::string` 这种对象，它在堆上分配了内存。

-   ==在 `union` 中==：如果你把 `age` 赋值给原本存有 `name` 的空间，`string` 指向的堆内存就==彻底丢失了（内存泄漏）==，因为没有东西去触发 `string` 的析构函数。
-   ==在 `std::variant` 中==：当你切换存储类型时，它会==先调用旧类型的析构函数==，再构造新类型。它像一个智能管家，确保不会有内存残留。

#### 3\. 禁止非法的隐式转换

虽然我们在第 77 集看到 `data = false` 会转换成 `int`，但 `variant` 整体上受到编译器的严格监视。如果你尝试存入一个完全不在列表中的类型（比如 `double`），编译器在==编译阶段==就会报错，而不会像 `void*` 或某些旧式 `union` 那样让你蒙混过关。

# 对ReadFileAsString的建议

```cpp
#ifdef LY_EP77

#include <iostream>
#include <variant>
#include <optional>
#include <fstream>
#include <sstream>

std::optional<std::string> ReadFileAsString(const std::string& filePath)
{
	std::ifstream stream(filePath);
	if (stream)
	{
		std::stringstream result;
		result << stream.rdbuf();
		//read file
		stream.close();
		return result.str();
	}
	return {};
}

//使用variant修改为更合理的方案

enum class ErrorCode
{
	None = 0,
	FileNotFound = 1,
	PermissionDenied = 2,
	UnknownError = 3
};
 
//如果成功则获取值，如果失败则获取错误码
std::variant<std::string, ErrorCode> ReadFileAsString()
{
	//省略
	return {};
}

int main()
{ 
	std::cin.get();

	return 0;
}
#endif
```
# 总结

==总结建议：== 如果你确切知道变量可能的几种类型（例如解析配置、处理特定错误码），请使用 `std::variant`。它兼顾了安全与性能。



