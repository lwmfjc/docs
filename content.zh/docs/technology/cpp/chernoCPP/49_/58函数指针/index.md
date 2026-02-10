---
title: 58函数指针
description: 58函数指针
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-02-10T23:42:53+08:00
lastmod: 2026-02-10T23:42:53+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
本篇聊聊==来自C语言的那种原始风格函数指针==，后续会讲C++处理函数指针的方法，以及lambda表达式    

- 函数指针，是一种把==函数赋给变量==的方式
- 函数只是个符号，并不能进行任何逻辑计算，但是可以拿来调用
- 可以接受传参，如果返回非void可以得到相应结果
- 函数可以赋值给变量，函数也可以作为参数传递给其他函数
- 函数是cpu指令，存储在我们的二进制文件中的某处
- `auto function = HelloWorld;`，获取cpu指令的内存地址并赋值给function

# 例子

```cpp
#include <iostream>  

void HelloWorld()
{
	std::cout << "HelloWorld!" << std::endl;
}

int main()
{
	//function的类型->void (*function)()
	auto function1 = &HelloWorld;
	//&可以省略，因为有隐式转换
	auto function = HelloWorld;
	//相当于
	void (*function2)() = HelloWorld;

	function();
	(*function)();
	function1();
	(*function1)();
	function2();
	(*function2)();
	std::cin.get();
}
```

## 隐式转换

1. 为什么不需要 &？
当你直接使用函数名 HelloWorld 时，编译器会将其视为该函数在内存中的起始地址。

- auto function = HelloWorld;：编译器看到函数名，自动将其转换为函数指针。
- auto function = &HelloWorld;：显式地取函数地址。

这两行代码生成的机器码通常是完全一样的。

2. 只有一种情况“必须”注意
虽然对于普通函数两者等价，但在处理类成员函数 (Member Functions) 时，规则会变严：

- 普通函数： & 可选。
- 类成员函数： 必须使用 & 并且加上类名限定。

例如：auto func = &MyClass::MemberFunction;（这里不能省略 &）。