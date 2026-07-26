---
title: 07链接器
description: 07链接器
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2025-12-13T17:12:49+08:00
lastmod: 2025-12-13T17:12:49+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
***07链接器***

# 介绍

编译器将C++ 源文件编译成.obj目标文件后，需要进行==链接==：==找到每个符号和函数的位置并将它们链接在一起==，在这之前每个文件都已经被编译成了一个单独的目标文件作为翻译单元，它们彼此之间没有任何联系  

Ctrl+F7只会编译文件，不会将文件链接；build项目会链接文件。  

```c++
#include <iostream>
const char* Log(const char* message) {
	return message;
}

int Multiply(int a,int b ) { 

	Log("Multiply");
	return  a * b;
}
```

编译实际上分为编译和链接两个阶段。如果上面代码去掉一个分号，则出现错误  
```shell
1>E:\cppStudyTemp\ChernoCpp\HelloWorld01\HelloWorld01\Math.cpp(10,1): error 
C2143: syntax error: missing ';' before '}' 
1>Done building project "HelloWorld01.vcxproj" -- FAILED.
========== Build: 0 succeeded, 1 failed, 0 up-to-date, 0 skipped ==========
========== Build completed at 17:51 and took 05.115 seconds ==========
```
这里C2143，==C开头表示是编译阶段的错误==  

补上后将整个项目build构建后，出现另一个错误：  

```shell
1>MSVCRTD.lib(exe_main.obj) : error LNK2019: unresolved external symbol main referenced in function "int __cdecl invoke_main(void)" (?invoke_main@@YAHXZ)
1>E:\cppStudyTemp\ChernoCpp\HelloWorld01\x64\Debug\HelloWorld01.exe : fatal error LNK1120: 1 unresolved externals
1>Done building project "HelloWorld01.vcxproj" -- FAILED.
```
这里出现LNK1120，==LNK开头表示链接阶段出现错误==  

## 指定程序入口

右键项目--属性 ，可以指定程序入口（所以并不一定必须是main函数）  

![](img/ly-20251213175705167.png)  

或者直接在程序里编写`#pragma comment(linker, "/ENTRY:haha")`  

必须禁用CRT调试功能才能编译成功，即：  

![](img/ly-20251213235052842.png)  

下面代码项目build成功：  

```c++
#pragma comment(linker, "/ENTRY:haha") 
int haha()
{     
    return 0;
}
```

目前我还不知道如何使用`std::cout << "hello"` ，目前要么报错要么没任何提示     

> 绕过main会跳过C++运行时的初始化：==全局/静态对象可能不会正确构造，atexit注册的函数不会被执行，异常处理可能无法工作==  

# 例子

## 编译错误
```c++
//Main.cpp
#include <iostream>
#添加声明，避免编译错误
void Log(const char* message);

int Multiply(int a, int b) {

	Log("Multiply");
	return a * b;

}

int main() {
	std::cout << Multiply(5, 8) << std::endl;
	std::cin.get();
}
```

如果没有`void Log(const char* message);`而去编译Main.cpp，会提示`1>E:\cppStudyTemp\ChernoCpp\HelloWorld01\HelloWorld01\Math.cpp(6,2): error C3861: 'Log': identifier not found ` 。   ~~编译错误~~ 

```c++
//Log.cpp

//没有这行会提示error C2039: 'cout': is not a member of 'std'
#include <iostream>

void Log(const char* message) {
	std::cout << message << std::endl;
}
```

现在可以右键项目名，build整个项目了  

## 链接错误

Main.cpp不变  

```c++
//Main.cpp
#include <iostream>
#添加声明，避免编译错误
void Log(const char* message);

int Multiply(int a, int b) {

	Log("Multiply");
	return a * b;

}

int main() {
	std::cout << Multiply(5, 8) << std::endl;
	std::cin.get();
}
```

*仅修改Log.cpp*文件，修改函数名Log为Logr

```c++
//Log.cpp

//没有这行会提示error C2039: 'cout': is not a member of 'std'
#include <iostream>
void Logr(const char* message) {
	std::cout << message << std::endl;
}
```

此时分别编译两个文件都成功了，继续build构建项目会提示出错：  
```shell
1>Math.obj : error LNK2019: unresolved external symbol "void __cdecl Log(char const *)" (?Log@@YAXPEBD@Z) referenced in function "int __cdecl Multiply(int,int)" (?Multiply@@YAHHH@Z)
1>E:\cppStudyTemp\ChernoCpp\HelloWorld01\x64\Debug\HelloWorld01.exe : fatal error LNK1120: 1 unresolved externals
```
未解析的外部符号Log，Multiply引用了它，但是它找不到要将它链接到哪个函数中  

如果将Multiply函数中的*调用Log*语句`Log("Multiply");`注释掉，则build项目成功无报错 ~~因为只有本文件内声明了Log但是又没用到，所以不会去链接他~~   

```c++
int Multiply(int a, int b) {
	//Log("Multiply");
	return a * b;
}
//========== Build: 1 succeeded, 0 failed, 0 up-to-date, 0 skipped ==========
```
如果将Main函数中的Multiply函数调用注释，则build照样提示链接错误  

```c++
//Main.cpp
#include <iostream>
void Log(const char* message);
int Multiply(int a, int b) {
	Log("Multiply");
	return a * b;

}
int main() {
	//std::cout << Multiply(5, 8) << std::endl;
	std::cin.get();
}

/*1>Math.obj : error LNK2019: unresolved external symbol "void __cdecl Log(char const *)" (?Log@@YAXPEBD@Z) referenced in function "int __cdecl Multiply(int,int)" (?Multiply@@YAHHH@Z)
1>E:\cppStudyTemp\ChernoCpp\HelloWorld01\x64\Debug\HelloWorld01.exe : fatal error LNK1120: 1 unresolved externals
1>Done building project "HelloWorld01.vcxproj" -- FAILED.
========== Build: 0 succeeded, 1 failed, 0 up-to-date, 0 skipped ========== */
```

为什么未使用它却没有删除它并且避免报错？因为虽然该文件(Main.cpp)没有使用Multiply，但是有可能另一个文件可能使用它（Multiply），所以链接器会链接它，要保证允许使用的函数都必须是可链接的  

> 1. 未被引用的函数，其内部代码依然会被编译：Multiply 函数虽然没有在 main 中被调用，但只要它存在于 .cpp 文件中，且没有被声明为静态（static）或内联（inline），编译器就会认为它是一个可以被其他翻译单元（其他 .cpp 文件）调用的全局函数。
> 2. 默认开启二进制生成：在 Debug 模式下，为了方便调试，编译器不会默认把“没被调用的代码”优化掉。Multiply 依然会被编译进 Math.obj。
> 3. 产生外部符号依赖：因为 Multiply 里面写了 Log("Multiply");，编译器在编译 Multiply 时，发现只有 Log 的声明（没有函数体），就会在 Math.obj 里打一个标记：“我需要一个叫做 void Log(const char*) 的函数，链接器你帮我在别的 .obj 里找找”。
> 4. 链接失败：链接器把所有 .obj 文件翻了个遍，都没找到 Log 的具体实现，于是抛出了 LNK2019 (unresolved external symbol) 错误。

## 消除链接的必要性

如果告诉链接器我只会在这个文件中使用它，如下，那么就可以消除链接的必要性：  

```c++
#include <iostream>
void Log(const char* message);
//添加了static 
static int Multiply(int a, int b) {
	Log("Multiply");
	return a * b;

}
int main() {
	//std::cout << Multiply(5, 8) << std::endl;
	std::cin.get();
}
```

Log.cpp文件没有任何修改

```c++
//Log.cpp
//没有这行会提示error C2039: 'cout': is not a member of 'std'
#include <iostream>
void Logr(const char* message) {
	std::cout << message << std::endl;
}
```

即使Log.cpp中函数名错误，此时build项目也不会报错  

## 完整的正确版本

Main.cpp
```c++
#include <iostream>
void Log(const char* message);
static int Multiply(int a, int b) {
	Log("Multiply");
	return a * b;
}
int main() {
	std::cout << Multiply(5, 8) << std::endl;
	std::cin.get();
}
```

Log.cpp
```c++
//没有这行会提示error C2039: 'cout': is not a member of 'std'
#include <iostream>
void Log(const char* message) {
	std::cout << message << std::endl;
}
```

------  

此时项目能正常build成功  

如果将Log函数的返回值修改为int，则build项目会出错
```c++
//没有这行会提示error C2039: 'cout': is not a member of 'std'
#include <iostream>
int Log(const char* message) {
	std::cout << message << std::endl;
	return 0;
}
```

# 重复相同签名的符号链接  

## 重复定义1

```c++
//Math.cpp
#include <iostream>
void Log(const char* message);
//注意，此处多了一个Log的重复定义(Log.cpp中有)
void Log(const char* message) {
	std::cout << message << std::endl;
}

static int Multiply(int a, int b) {
	Log("Multiply");
	return a * b;

}

int main() {
	std::cout << Multiply(5, 8) << std::endl;
	std::cin.get();
}
```

```c++
//Log.cpp
#include <iostream>
void Log(const char* message) {
	std::cout << message << std::endl;
}
```

这两文件，分别单独编译，都是成功的。但是如果build项目，则提示`error LNK1169: one or more multiply defined symbols found`  ~~链接错误~~   
```shell
1>LINK : E:\cppStudyTemp\ChernoCpp\HelloWorld01\x64\Debug\HelloWorld01.exe not found or not built by the last incremental link; performing full link
1>Math.obj : error LNK2005: "void __cdecl Log(char const *)" (?Log@@YAXPEBD@Z) already defined in Log.obj
1>E:\cppStudyTemp\ChernoCpp\HelloWorld01\x64\Debug\HelloWorld01.exe : fatal error LNK1169: one or more multiply defined symbols found
1>Done building project "HelloWorld01.vcxproj" -- FAILED.
```

## 重复定义2

```c++
//Log.h

#pragma once
//当在同一个源文件中被多次包含时，使用 #pragma once 可以确保该头文件的内容只被编译一次。

void Log(const char* message) {
	std::cout << message << std::endl;
}
```

```c++
//Log.cpp

#include <iostream>
#include "Log.h"

void InitLog() {
	Log("initialized");
}
```

```c++
//Math.cpp
#include <iostream>
#include "Log.h"

static int Multiply(int a, int b) {
	Log("Multiply");
	return a * b;

}

int main() {
	std::cout << Multiply(5, 8) << std::endl;
	std::cin.get();
}
```

代码中没有显示的出现两次Log函数的定义，但是为什么提示下面这种==链接==错误 ~~重复定义~~   

```shell
1>E:\cppStudyTemp\ChernoCpp\HelloWorld01\x64\Debug\HelloWorld01.exe : fatal error LNK1169: one or more multiply defined symbols found

```

这是因为头文件被重复包含了两次，预编译期间会把头文件的内容拿来替换`#include "Log.h"`，所以其实Log.cpp和Math.cpp都包含了Log的定义 ~~(不是声明，是定义)~~ 

### 解决方案-static

将Log.h中的Log函数定义设置为static，那么被include之后发生在这个对数函数上的链接只是内部的，只在该文件中有效，对其他目标文件是不可见的(消除了链接的必要性)  
```c++
//Log.h

#pragma once
//当在同一个源文件中被多次包含时，使用 #pragma once 可以确保该头文件的内容只被编译一次。

static void Log(const char* message) {
	std::cout << message << std::endl;
}
```

### 解决方案-inline

inline，内联，将采用我们的实际函数==体==并用它替换调用  

```c++
//Log.h

#pragma once
//当在同一个源文件中被多次包含时，使用 #pragma once 可以确保该头文件的内容只被编译一次。

inline void Log(const char* message) {
	std::cout << message << std::endl;
}

```

即Log.cpp  

```c++
#include <iostream>
#include "Log.h"

void InitLog() {
	Log("initialized");
}
```

编译后会变成  

```c++
#include <iostream>
#include "Log.h"

void InitLog() {
	std::cout << “initialized” << std::endl;
}
```

### 解决方案-定义独立

Log.h中只有对Log函数的声明  

```cpp
//Log.h
#pragma once
//当在同一个源文件中被多次包含时，使用 #pragma once 可以确保该头文件的内容只被编译一次。
void Log(const char* message);
```

Log.cpp中有对Log函数的定义  

```cpp
//Log.cpp

#include <iostream>
#include "Log.h"

void InitLog() {
	Log("initialized");
}

//实际要链接的函数
void Log(const char* message) {
	std::cout << message << std::endl;
}
```

Math.cpp不变  

```cpp
#include <iostream>
#include "Log.h"

static int Multiply(int a, int b) {
	Log("Multiply");
	return a * b;

}

int main() {
	std::cout << Multiply(5, 8) << std::endl;
	std::cin.get();
}
```

# 总结

链接器需要获取编译器件生成的所有目标文件，并将它们全部链接在一起，还会引入我们可能正在使用的任何其他库，例如C运行时库，C++标准库，以及平台api和其他很多东西。从许多不同的地方进行链接是常见的，还有不同类型的链接，还有==静态链接和动态链接(后面会讲到)==  