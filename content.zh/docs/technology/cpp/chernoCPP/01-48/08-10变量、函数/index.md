---
title: 08-10变量、函数
description: 08-10变量、函数
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2025-12-15T14:17:30+08:00
lastmod: 2025-12-15T14:17:30+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 变量

- ==编程实际上就是在操纵数据==  
- 变量允许我们==命名一个我们存储在内存中的数据==  
- 我们创建的变量存储在堆栈或堆中  
- 原始数据是构成任何种类的基石
- 不同的变量类型，唯一的区别，是存储他们需要多少内存(原始数据类型有多大)  
## 整数

```cpp
#include <iostream>

int main() {

	int variable = 8;
	std::cout << variable << std::endl;
	variable = 20;
	std::cout << variable << std::endl;
	std::cin.get();
}
```

- int变量通常上是4字节，取决于编译器
- 可以不用立即赋值
- 大概在-20亿~+20亿之间  
- 4字节是32位，int是有符号的，第32位存储符号位。还剩下31位存储数据。2^31=21 4748 3648 。  
	- 最大正数：2^31-1=21 4748 3647
	- 最小负数：-(2^31)=-21 4748 3648  
	- 为什么负数多一个，因为多了一个"-0"但int中没有-0的 ~~浮点数中有-0.0的概念~~ 概念，二进制10000000 00000000 00000000 00000000 代表-(2^31)
- unsint 表示无符号整数，能用上所有的位，即最大整数是(2^32) -1
- 其他：char 1字节，short 2字节，int 4字节，long 通常4字节，long long 通常8字节   ~~由于32位系统最大是4字节，所以long也是4字节。后来出了64位系统，64位windows系统中long是4字节，64位Linux/macOS中long是8字节~~   可以给任何一个前面加unsigned表示无符号

```cpp

	char cVariable = 'A';
	//char cVariable=65;
	//不管是用65还是'A'赋值，打印出来的都是A
	std::cout << cVariable << std::endl;
	
	
	short sVariable = 'A';
	//short cVariable=65;
	//不管是用65还是'A'赋值，打印出来的都是65
	std::cout << sVariable << std::endl;
```

## 小数

```cpp
	float fVariable = 8.2f;//4字节
	std::cout << fVariable << std::endl;
	double dVariable = 20.3;//8字节
	std::cout << dVariable << std::endl;
```

## 布尔值

布尔类型只占用1个字节（只需要1位，但我们在处理内存寻址时，即我们要从那里取回我们的值时，或者将它存储在内存体重时，没有办法只处理个别位，所以只能按字节取）    

0表示假，除了0以外的任何值表示真  

```cpp
	bool bVariable = true;
	std::cout << bVariable << std::endl;//1
	bVariable = false;
	std::cout << bVariable << std::endl;//0
	bVariable = 322;
	std::cout << bVariable << std::endl;//1
	std::cin.get();
```

## 数据类型大小

检查变量占用多少字节  
```cpp
	std::cout << sizeof(bVariable) << std::endl; //1
```

不要假设某个数据类型是多大，而是明确指出需要几个字节的数据类型，例如  
```cpp
    // 固定宽度有符号整数
    int8_t  small;      // 明确8位，范围：-128 ~ 127
    int16_t medium;     // 明确16位，范围：-32768 ~ 32767
    int32_t standard;   // 明确32位，范围：-2.1e9 ~ 2.1e9.2e18 ~ 9.2e18 
    int64_t large;      // 明确64位，范围：-9.2e18 ~ 9.2e18
    
    // 固定宽度无符号整数
    uint8_t  u_small;   // 0 ~ 255
    uint16_t u_medium;  // 0 ~ 65535
    uint32_t u_standard;// 0 ~ 4.3e9
    uint64_t u_large;   // 0 ~ 1.8e19
```

# 函数

- 函数的基本构成是代码块，编写函数的目的是稍后执行特定任务时，进入那些被称为“块”的东西
- 函数具有输出和输入
- 当我们每调用一个函数时，编译器生成调用指令，意味着每次执行函数需要创建函数需要的堆栈框架，里面包括参数、返回地址之类的东西；之后跳转到实际的不同部分的代码块（二进制文件）执行，之后返回需要获取的值 ~~所以有时候需要内联函数~~ 
- 普通函数（非main函数）必须显示指定返回值 (return xxx;)，main函数如果没指定，会默认return 0;
## 例子
```cpp
#include <iostream>

int Multiply(int a, int b) {
	return a * b;
}

void MultiplyAndLog(int a, int b) {
	int result = Multiply(a, b);
	std::cout << result << std::endl;
}

int main() {

	MultiplyAndLog(3, 2);
	MultiplyAndLog(8, 5);
	MultiplyAndLog(90, 45);


	int result = Multiply(3, 2);
	std::cout << result << std::endl;


	int result2 = Multiply(8, 5);
	std::cout << result2 << std::endl;


	int result3 = Multiply(90, 45);
	std::cout << result3 << std::endl;

	std::cin.get();

}
```

# 头文件

- 头文件传统上是为了声明某些类型或函数确实存在
	- 假设我们在一个文件中创建了一个函数、我们想在另一个文件中使用它，如果不提前声明那么就无法识别
	- 我们需要一个==共同的地方==来仅声明（而非定义）这个函数确实存在，然后就可以给其他文件include了（也不会导致重复定义）
## 例子

```cpp
//Log.h
#pragma once
void Log(const char* message);
void InitLog();//必须声明，因为Main10.cpp中调用了该函数
```

```cpp
#include <iostream>
#include "Log.h" //必须include用以声明，否则会提示 'Log': identifier not found

void InitLog() {
	Log("Initializing Log");//!!!没有include Log.h这里会报错
}

void Log(const char* message) {
	std::cout << message << std::endl;
}
```

```cpp
//Main10.cpp
#include <iostream>
#include "Log.h"

int main() {
	InitLog();//调用了Log.app中的函数
	Log("hello world!");
	std::cin.get():
}
```

## pragma

- `#pragma once` 称为预处理命令或预处理指令
- pragma是发给编译器或预处理器的指令，once意味着只包含（include）此文件一次，阻止我们包含同一个头文件多次放入==同一个==单个翻译单元
- 如果x.h包含了y.h，a.cpp又包含了x.h和y.h，如果y.h中写了`#pragma once`，则y.h不会被包含两次

视频中举了个例子，比如在test.h中包含了`struct Name {};` 而a.cpp和b.cpp都`#include test.h`。为什么这里允许(不同文件中存在)结构体定义重复，不允许函数定义重复？
- ==结构体（类型信息）不生成链接符号==：结构体定义只告诉编译器"Name类型有多大，有什么成员"
- 本地信息：每个.obj文件只需要知道如何处理Name类型的变量
- ==不需要链接器参与==：类型信息不参与链接过程

## HeaderGuards

Header guards（头文件保护）是C/C++中==防止头文件被多次包含==的预处理技术。  

修改Log.h头文件  

```cpp
//Log.h 
//#pragma once
#ifndef _LOG_H
#define _LOG_H

void Log(const char* message);
void InitLog();

struct A {};

#endif
```

# `include <>` 和 `include ""` 区别

## 尖括号-搜索顺序

1. ==-I== 指定的路径（按命令行出现顺序从左到右）
2. 系统==环境变量==指定的路径
3. ==编译器==内置路径（最后查找标准库）

> 
> 解释一下系统环境变量
> 1. Windows / Visual Studio (MSVC)：
>    ==INCLUDE 环境变量==：Visual Studio 和 MSVC 命令行工具（如 cl.exe）依靠这个变量来定位头文件路径。当你通过 VS 安装第三方库（如 DirectX SDK）或自定义工具链时，常常会将头文件路径添加到系统的 INCLUDE 变量中。
> 2. Linux / GCC / Clang：
>   ==C_INCLUDE_PATH==：用于 C 语言寻找头文件的路径。==CPLUS_INCLUDE_PATH / CPATH==：用于 C++ 语言寻找头文件的路径。
>   

## 双引号-搜索顺序

1. 当前文件所在目录（还可以使用相对目录，比如`#include "../Log.h"`）
2. 尖括号的所有搜索路径
## 最佳实践

- 标准库、第三方库：使用 `<>`
- 项目自己的头文件：使用 `""`
- 当不确定时：通常用 `""` 更安全，因为它会先搜索当前目录
- C标准库通常有`.h`结尾，例如`#include <stdlib.h>`
- C++标准库一般没有后缀，例如`#include <iostream>`
