---
title: 36三元运算符
description: 36三元运算符
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-01-10T22:03:11+08:00
lastmod: 2026-01-10T22:03:11+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
if-else的语法糖  

# 初试

```cpp
#include <iostream>
#include <string>

static int s_Level = 12;
static int s_Speed = 2;

int main()
{

	if (s_Level > 5)
		s_Speed = 10;
	else
	{
		s_Speed = 5;
	}

	s_Speed = s_Level > 5 ? 10 : 5;
	//嵌套
	// 
	//s_Level > 5 && s_Level < 100 这个会先被连接在一起判断
	s_Speed = s_Level > 5 && s_Level < 100 ? s_Level > 10 ? 15 : 10 : 5;

	//如果>5的情况下，如果还>10，则15，如果不大于10则10；否则(不
	//>5)，则5
	s_Speed = s_Level > 5 ? s_Level > 10 ? 15 : 10 : 5;


	//方式1：这里没有多构造空对象其实和编译器有关，后面会说到
	std::string rank = s_Level > 10 ? "Master" : "Beginer";

	//方式2：这种声明方式，还会比上面额外多构造一个空字符串对象
	std::string otherRank;
	if (s_Level > 10)
		otherRank = "Master";
	else
		otherRank = "Beginer";

	std::cout << s_Speed << std::endl; //15

	std::cin.get();
}
```

# 解释一下方式2

编译器并不会先创建一个临时的 std::string 之后再拷贝给 rank。它的执行逻辑如下：

- 确定目标：编译器知道它正在为一个名为 rank 的新变量分配空间。
- 求值：计算三元运算符的结果。结果是一个字符串字面量（const char*）。
- 就地构造：编译器直接调用 std::string(const char*) 构造函数，将 rank 的内存空间作为操作目标。

