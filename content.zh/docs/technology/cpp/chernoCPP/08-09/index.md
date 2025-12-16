---
title: 08-09变量、函数
description: 08-09变量、函数
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
- 变量允许我们命名一个我们存储在内存中的数据  
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
	- 最小负数：-(2^31)=21 4748 3648  
	- 为什么负数多一个，因为多了一个"-0"但计算机中没有-0的概念，二进制10000000 00000000 00000000 00000000 代表-(2^31)
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
    int32_t standard;   // 明确32位，范围：-2.1e9 ~ 2.1e9
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
- 
