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

# VisualStudio

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

