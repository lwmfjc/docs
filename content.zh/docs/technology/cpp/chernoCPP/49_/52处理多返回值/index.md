---
title: 52处理多返回值
description: 52处理多返回值
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-02-08T23:14:14+08:00
lastmod: 2026-02-08T23:14:14+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
这篇讨论的是如何在函数返回两个值  

cherno推荐的方法是创建一个结构体并返回它  

# 代码预备 

为了演示，本篇使用了string，为了顺便探讨性能（视频中没提到），我写了一个string.h 和string.cpp打印相关信息  

```cpp
//String.h
#pragma once // 防止头文件被重复包含
#include <iostream>

class String
{
private:
    char* m_Buffer;
    unsigned int m_Size;

public:
    // 默认构造函数
    String() : m_Buffer(nullptr), m_Size(0) {}

    // 构造函数
    String(const char* string);

    // 拷贝构造函数（深拷贝）
    //拷贝构造函数 (String a = b;)：当你在创建一个新的对象，并用已有的对象初始化它时调用。
    String(const String& other);

    // 析构函数
    ~String();

    // 运算符重载
    char& operator[](unsigned int index);

    // 赋值运算符重载 (a = b;)：当两个对象都已经存在（已经构造完毕），你只是想把其中一个的值覆盖给另一个时调用。
    String& operator=(const String& other); 

    // 友元函数：重载 << 运算符
    friend std::ostream& operator<<(std::ostream& stream, const String& string);

    // 测试函数
    unsigned int& mytest() { return m_Size; } // 简单的内联函数可以直接写在类内
};
```

```cpp
#include "String.h"
#include <cstring> // 必须包含 cstring 才能使用 strlen 和 memcpy

// 构造函数
String::String(const char* string)
{
	m_Size = strlen(string);
	m_Buffer = new char[m_Size + 1];
	memcpy(m_Buffer, string, m_Size);
	m_Buffer[m_Size] = '\0';
}

// 拷贝构造函数
String::String(const String& other)
	: m_Size(other.m_Size)
{
	std::cout << "Copied String!" << std::endl;
	m_Buffer = new char[m_Size + 1];
	memcpy(m_Buffer, other.m_Buffer, m_Size + 1);
}

//赋值运算符 
String& String::operator=(const String& other)
{
	std::cout << "Assignment Operator Called!" << other << std::endl;

	// 1. 自赋值检查 (防止 s1 = s1 的骚操作)
	if (this == &other)
		return *this;

	// 2. 释放当前对象旧的内存，防止内存泄漏
	delete[] m_Buffer;

	// 3. 申请新空间并拷贝内容
	m_Size = other.m_Size;
	m_Buffer = new char[m_Size + 1];
	memcpy(m_Buffer, other.m_Buffer, m_Size + 1);

	// 4. 返回对象自身，支持链式赋值 (a = b = c)
	return *this;
}

// 析构函数
String::~String()
{
	delete[] m_Buffer;
}

// 下标运算符重载
char& String::operator[](unsigned int index)
{
	return m_Buffer[index];
}

// 友元函数定义（注意：定义时不需要加 String::，也不需要加 friend 关键字）
std::ostream& operator<<(std::ostream& stream, const String& string)
{
	stream << string.m_Buffer;
	return stream;
}
```

# 方法1：使用引用

```cpp
#include <iostream>
#include "String.h"

void ParseShader(String& vertexSource, String& fragmentSource)
{
	//假设vs，fs最终计算值是abc、def
	String vs = "abc";
	String fs = "def";

	//这两行代码执行的是 字符串赋值(内部会拷贝)
	vertexSource = vs;
	fragmentSource = fs;
}

int main()
{
	String vs, fs;
	ParseShader(vs, fs);
	std::cout << vs << std ::endl;
	std::cout << fs << std::endl;
	std::cin.get();
}
/*
Assignment Operator Called!abc
Assignment Operator Called!def
abc
def

*/
```

# 方法2：使用指针

```cpp
#include <iostream>
#include "String.h"

void ParseShader(String* vertexSource, String* fragmentSource)
{
	//假设vs，fs最终计算值是abc、def
	String vs = "abc";
	String fs = "def";

	//这两行代码执行的是 字符串赋值(内部会拷贝)
	if (vertexSource) {
		*vertexSource = vs;
	}
	if (fragmentSource) {
		*fragmentSource = fs;
	} 
}

int main()
{
	String vs, fs;
	ParseShader(&vs, &fs);
	//这种方式允许空指针
	//ParseShader(nullptr, &fs);
	std::cout << vs << std::endl;
	std::cout << fs << std::endl;
	std::cin.get();
}
/*
Assignment Operator Called!abc
Assignment Operator Called!def
abc
def
*/
```

# (同类型)方法3：返回(数组)指针

```cpp
#include <iostream>
#include "String.h"

String* ParseShader()
{
	//假设vs，fs最终计算值是abc、def
	//vs,fs先在栈上创建（但String成员m_Buffer是指向堆）
	String vs = "abc";
	String fs = "def";

	//这种语法在c++20才能编译通过
	return new String[]{ vs,fs };
} 

int main()
{ 
	//这里不知道数组有多大
	String* result =ParseShader();

	std::cout << result[0] << std::endl;
	std::cout << result[1] << std::endl;
	std::cin.get();
}
/*
Assignment Operator Called!abc
Assignment Operator Called!def
abc
def
*/
```

*分析：*  

1. 准备阶段： vs 和 fs 在栈上出生，它们分别在堆上申请了空间存放 "abc" 和 "def"。
2. 关键动作：return new String[]{ vs, fs };
	- 堆分配：在堆上开辟了一块新空间，足以存放两个 String 对象。
	- 拷贝构造：调用 String 的拷贝构造函数，把 vs 和 fs 的内容“复制”到这块新堆空间里。
	- 重点：此时，内存里有两份 "abc" 和 两份 "def"（都在堆上）。
3. 函数结束（执行到 }）：
	- 局部变量 vs 和 fs 的寿命到了，它们的析构函数被触发。
	- vs 析构函数执行 delete[] m_Buffer，销毁了它原本的那份 "abc"。
	- 但是，刚才 new 出来的那个数组里的 "abc" 依然存在，因为它属于另一块堆内存。

# (同类型)方法4：返回array

```cpp
#include <iostream>
#include <array>

#include "String.h"

std::array<String,2> ParseShader()
{
	//假设vs，fs最终计算值是abc、def
	//vs,fs先在栈上创建（但String成员m_Buffer是指向堆）
	String vs = "abc";
	String fs = "def";
	std::array<String, 2> results;
	//触发了 String 类的拷贝赋值运算符（Assignment Operator）
	//此时 results[0] 内部的 m_Buffer 会申请一块新堆内存，并将 vs 指向的内容复制过来。现在内存中有两份 "abc"。
	results[0] = vs;
	results[1] = fs; 

	//由于现代编译器的 RVO（返回值优化），results 数组通常不会被拷贝，而是直接在 main 函数的 result 变量位置“原地出生”。且result指向的是上面申请的新堆内存
	return  results;
}

int main()
{
	std::array<String, 2> result = ParseShader();

	std::cout << result[0] << std::endl;
	std::cout << result[1] << std::endl;
	std::cin.get();
}
/*
Assignment Operator Called!abc
Assignment Operator Called!def
abc
def
*/
```

解释一下如果没有RVO优化  

第一步：从 results (原件) 到 “中转站” (副本1)
当执行 return results; 时：

- 编译器需要==在中转区构造==一个 std::array<String, 2> 的临时对象。
- 因为 std::array 的拷贝本质上是循环对其成员进行拷贝，所以它会调用 results[0] 和 results[1] 的拷贝构造函数。
- ==String 的表现：你的深拷贝代码被触发==！
	- 申请新堆内存，把 "abc" 拷进去。
	- 申请新堆内存，把 "def" 拷进去。
- 状态：==此时内存里存在三份数据（局部变量、数组原件、中转站副本）==。

第二步：函数销毁（清理原件）
ParseShader 的栈帧销毁。

- 局部变量 vs/fs 以及 results 数组被析构。
- String 的表现：触发析构函数，delete[] 掉它们持有的堆内存。
- 结果：==最初的那两份堆内存消失了，但“中转站”里的那份副本还活着==。

第三步：从 “中转站” 到 main 的 result (最终目的地)
回到 main 函数执行 std::array<String, 2> result = ParseShader();：

- 编译器需要==把中转站里的临时对象拷贝给 result==。
- String 的表现：再次触发深拷贝！
	- 再次申请新堆内存，再次 memcpy 拷贝 "abc" 和 "def"。
- 结果：又产生了一套全新的堆内存。

第四步：清理中转站
- ==临时对象完成任务，被销毁==。
- 执行析构函数，释放中转站刚才持有的堆内存。

# (同类型)方法5：返回vector

```cpp
#include <iostream>
#include <vector>

#include "String.h"

std::vector<String> ParseShader()
{
	//假设vs，fs最终计算值是abc、def
	//vs,fs先在栈上创建（但String成员m_Buffer是指向堆）
	String vs = "abc";
	String fs = "def";
	std::vector<String> results;
	//触发了 String 类的拷贝函数 
	results.push_back(vs);//第一次拷贝
	results.push_back(fs); //容量不够触发了第二次和第三次拷贝
	 
	return  results;
}

int main()
{
	std::vector<String> result = ParseShader();

	std::cout << result[0] << std::endl;
	std::cout << result[1] << std::endl;
	std::cin.get();
} 
```

为了和方法4对比，这里做一个分析 ~~针对 `return results;`~~

1. 远古时代（C++98/03）：一定会深度拷贝
在这个时代，没有“移动语义”这个概念。
- 执行逻辑：当 return results; 发生且 RVO 失败时，vector 必须保证数据的安全。因为它不知道自己是要被“移动”还是“复制”，所以它只能选择最稳妥的办法——克隆。
- 后果：
	- 从 results 拷贝到“中转站”：vector 调用 String 的拷贝构造函数。String 申请新空间，memcpy 内容。(深拷贝 1)
	- 从中转站拷贝到 result：再次调用 String 的拷贝构造函数。(深拷贝 2)
- 结论：在这个时代，你的分析是完全正确的 ~~一共多出了两次深度拷贝~~ 。

2. 现代时代（C++11 到 C++20）：只复制指针
这是你目前所处的时代。引入了 ==“移动语义（Move Semantics）”==。
- 执行逻辑：
	- C++ 标准规定，当一个局部变量（如 results）被 return 时，它被视为一个“即将消失的东西”（右值）。
	- 编译器会优先寻找 vector 和 String 的移动构造函数，而不是拷贝构造函数。
- 物理动作：
	- 移动 vector：直接把 results 里的三个指针（钥匙）复制给中转站，然后把 results 里的指针置为空。
	- 移动 String：vector 在转移过程中，会让里面的 String 也执行移动。String 的移动构造函数只是把 m_Buffer 的地址传给新对象。
- 结论：此时只复制了指针（约 24 字节），完全没有 new[] 和 memcpy。 即使 RVO 失败，性能依然极高。

3. 超现代时代：RVO 强制执行
在 C++17 及以后（你用的是 C++20），情况变得更加极端。
- 强制优化：对于某些特定的返回场景，标准规定编译器必须执行 RVO（这种强制的 RVO 叫 Guaranteed Copy Elision）。
- 物理动作：
	- 连“中转站”这个概念都被取消了。
	- results 变量从出生那天起，就直接住在了 main 函数为 result 预留的地址里。
- 结论：指针拷贝次数 = 0，String 深拷贝次数 = 0。
# 方法5：元组

```cpp
#include <iostream>
#include <utility> 

#include "String.h"


std::tuple<String,String> ParseShader()
{
	//假设vs，fs最终计算值是abc、def 
	String vs = "abc";
	String fs = "def"; 

	//std::make_pair 是一个按值传递（Pass by Value）的函数。
	return  std::make_pair(vs,fs);
}

int main()
{

	//std::tuple<String, String> result = ParseShader();
	ParseShader();
	std::cout << "======" << std::endl;
	/*std::cout << std::get<0>(result) << std::endl;
	std::cout << std::get<1>(result) << std::endl; */
	std::cin.get();
}
/*
Copied String!abc
Copied String!def
Copied String!def
Copied String!abc
======
*/
```

当编译器执行到 return std::make_pair(vs, fs); 时，逻辑流如下：

1. 构造临时 Pair：std::make_pair 首先在函数内部构造出一个 std::pair<String, String> 对象。为了填满这个 pair，它会从参数中拷贝构造 vs 和 fs（这就是你看到的前两次输出）。
2. 发现类型不匹配：编译器看到函数需要返回 tuple，但手里拿的是 pair。
3. 调用转换构造函数：编译器调用 tuple 的转换构造函数，这个构造函数会执行类似于下面的逻辑：
	- `tuple.member[0] = pair.first;`
	- `tuple.member[1] = pair.second;`
4. 触发深拷贝：==由于 pair 里的两个 String 都是左值==（即它们是有名字的变量，不是临时变量），tuple 在初始化自己的成员时，必须通过 String 的拷贝构造函数把 pair 里的内容“克隆”一份。
	- 这一步产生了你看到的后两次 Copied String!。

## 解释“由于 pair 里的两个 String 都是左值”

### 1. 什么是“左值” (Lvalue)？
在 C++ 中，**左值**是指那些**有明确名字、有持久内存地址**的对象。
在你的代码里：
* `vs` 和 `fs` 是左值。
* 当它们被装进 `std::pair` 后，`pair.first` 和 `pair.second` 依然是左值。

**左值的特性是**：它们在当前语句结束后**还要继续存在**。
### 2. 为什么左值必须“克隆”？
想象一下编译器在执行 `tuple` 转换构造函数时的心理活动：
* **看到来源**：编译器发现要从一个 `pair` 里拿数据。
* **身份检查**：编译器检查 `pair.first`（即字符串 "abc"）。它发现这是一个**左值**（有名字的变量）。
* **安全评估**：编译器心想：“这个 `pair.first` 以后可能还要被别人使用，我不能直接把它的堆内存（`m_Buffer`）偷走。如果我偷走了，原主人的指针就变成 `nullptr` 了，程序后面再用它就会崩溃。”
* **做出决定**：为了绝对安全，编译器只能下令：“调用**拷贝构造函数**，重新申请一块内存，把内容克隆一份给 `tuple`。”
### 3. 如果是“右值”会怎样？
如果你告诉编译器：“这个对象我再也不用了，你可以随便破坏它”，这就是**右值** (Rvalue)。
如果你写 `return std::make_tuple(std::move(vs), std::move(fs));`：
* **std::move 的作用**：它把左值 `vs` 强制转换成右值。
* **编译器心态转变**：编译器心想：“主人说了这个 `vs` 是个临时工（右值），不用留活路。那我不克隆了，直接把它的 `m_Buffer` 指针**偷**过来给 `tuple`。”
* **结果**：这就是**移动构造**。只需要拷贝一个 8 字节的地址，**0 次深拷贝**。
### 4. 总结这个“由于”的逻辑链
- 由于 `pair` 里的 `String` 是左值 
- **意味着** 它们在逻辑上需要保持完整性 
- **导致** 编译器不敢执行“破坏性”的移动 
- **必须** 调用拷贝构造函数进行深拷贝。

## 左值右值进一步解释 

之所以研究左右值，就是为了性能。

- 以前（只有拷贝）：不管你是左值还是右值，返回对象时一律按照“信件”处理，必须找个新信箱复印一份（深拷贝）。
- 现在（有了移动）：如果你发现对方是一个右值（即将销毁的临时信箱），你可以直接把那个信箱底部的地址标牌拆下来换成自己的。

这就是为什么 std::move 叫“移动”——它把一个原本稳固的“左值”强行标记为“右值”，告诉编译器：“这个信箱我不要了，随便拆！”

总结
- 左：Location（有地盘，能长期住）。
- 右：Read-only / Release（临时路过，用完即焚）。


# 方法6：二元组、对 (pair)

```cpp
#include <iostream>
#include <utility> 

#include "String.h"


std::pair<String,String> ParseShader()
{
	//假设vs，fs最终计算值是abc、def 
	String vs = "abc";
	String fs = "def"; 

	//std::make_pair 是一个按值传递（Pass by Value）的函数。
	return  std::make_pair(vs,fs);
}

int main()
{

	std::pair<String, String> result = ParseShader(); 
	std::cout << "======" << std::endl;
	std::cout << std::get<0>(result) << std::endl;
	std::cout << std::get<1>(result) << std::endl;
	std::cout << result.first << std::endl;
	std::cout << result.second << std::endl;
	std::cin.get();
}
/* 注意，这里只调用了一次复制构造函数，和上面方法5的理论分析一致，没有进行std::pair向std::turple的转换

Copied String!abc
Copied String!def
======
abc
def
abc
def

*/
```