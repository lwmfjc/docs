---
title: 39显式转换和隐式转换
description: 39显式转换和隐式转换
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-01-11T14:56:35+08:00
lastmod: 2026-01-11T14:56:35+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
隐式转换表示你没有明确告诉他你要这么做  

```cpp
#include <iostream>
#include <string>  

class Entity
{
private:
	std::string m_Name;
	int m_Age;

public:

	//加上explicit则拒绝隐式转换
	/*explicit*/ Entity(const std::string& name)
		:m_Name(name), m_Age(-1) {
	}

	/*explicit*/ Entity(int age)
		:m_Name("Unknown"), m_Age(age) {
	}

};

void PrintEntity(const Entity& entity)
{

}

int main()
{
	//直接初始化，直接寻找匹配的构造函数，不属于隐式转换
	Entity a("Cherno");
	Entity b(22);

	//违反了“最多只能进行一次用户自定义转换”的原则
	//先从const char[7]转换为std::string
	//然后从std::string转换为Entity
	//Entity a1 = "Cherno";
	//PrintEntity("Cherno");

	//隐式转换
	Entity a1 = std::string("Cherno");
	Entity b2 = 22;
	//建议这样书写简单明了
	//Entity b3(22);

	//隐式转换
	PrintEntity(22);
	PrintEntity(std::string("Cherno"));

	//只进行一次转换，把 const char[7]转换为std::string
	//这里没有涉及到把xx转换为Entity，所以即使
	// explicit Entity(const std::string& name)也
	//能编译通过
	PrintEntity(Entity("Cherno"));

	//强制显式转换
	Entity a3 = (Entity)"Cherno";
	//不转换而是直接调用构造函数
	Entity a3 = Entity("Cherno");

	std::cin.get();
}
```