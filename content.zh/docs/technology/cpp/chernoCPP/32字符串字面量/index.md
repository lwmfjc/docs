---
title: 字符串字面量
description: 字符串字面量
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-01-01T19:26:44+08:00
lastmod: 2026-01-01T19:26:44+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
特殊情况  

```cpp
#include <iostream>
#include <stdlib.h>
#include <string>

int main()
{
	//(const char [7])"Cherno"，7字节，因为末尾有一个空字符'\0'
	"Cherno";
	std::cout << "Cher\0no" << std::endl;//Cher

	const char name[8] = "Che\0rno";

	std::cin.get();
}
```

![](img/ly-20260102194456478.png)  

# 注意事项

```cpp
#include <iostream>
#include <stdlib.h>
#include <string>

int main()
{
	//(const char [7])"Cherno"，7字节，因为末尾有一个空字符'\0'
	"Cherno";
	std::cout << "Cher\0no" << std::endl;//Cher

	const char name[8] = "Che\0rno";
	std::cout << strlen(name) << std::endl;//3,不把\0算在内

	/* 错误的，某些编译器允许编译通过,但没效果
	char* name1 = "Cherno";
	name1[2] = 'a';
	std::cout << name1 << std::endl;//Cherno
	*/

	//一定要修改的话
	char name2[] = "Cherno";
	name2[2] = 'a';
	std::cout << name2 << std::endl;//Charno

	std::cin.get();
}
```

# 不同类型的字符串

```cpp
#include <iostream>

int main()
{
	const char* name = "Cherno";
	const char* name_ = u8"Cherno";

	//字符串中的每个字符都是宽字符（wchar_t 类型）,
	//通常是16位或32位，取决于系统(大小平台相关)
	//L 前缀表示这是一个宽字符字符串
	const wchar_t* name2 = L"Cherno";

	// C++11后的UTF-16字符串,固定每个字符2字节
	const char16_t* name3 = u"Cherno";

	// C++11后的UTF-32字符串,固定每个字符4字节
	const char32_t* name4 = U"Cherno";

	std::cin.get();
}
```

