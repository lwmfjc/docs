---
title: 17引用
description: 17引用
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2025-12-29T22:13:50+08:00
lastmod: 2025-12-29T22:13:50+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
> 需要有pointer(指针)，即上一个视频的基础

> 引用其实是指针的扩展，只是指向指针的语法糖，让他更容易阅读。引用本质上是引用现有变量，不同于指针，你可以在其中创建新的指针变量让后将其设置为空指针或其他。引用本身实际上并不占据新变量，他们实际上没有存储空间。

```cpp
	int a = 5;
	int* b = &a;

	//&符号是类型的一部分
	//使用ref就跟使用a的别名一样
	int& ref = a;
	//这里编译器编译后会直接设置a，而
	//不会再创建一个变量
	ref = 2;

	LOG(a); //5
```

# 使用地址增加

```cpp
void Increment(int* value) {
	//首先引用指针，然后增加指针处的值
	(*value)++;
}

int main()
{

	int a = 5;
	Increment(&a);
	LOG(a);

	std::cin.get();
}
```

使用引用实现一样的效果，但是代码更加美观  
```cpp
void Increment(int& value) {
	value++;
}

int main()
{

	int a = 5;
	Increment(a);
	LOG(a);

	std::cin.get();
}
```

# 引用的禁忌

不能指向其他地方

```cpp

void Increment(int& value) { 
	value++;
}

int main()
{

	int a = 5;
	int b = 8;
	//必须初始化，否则编译错误
	int& ref = a;
	
	//不会出现编译错误，但是其实没有任何效果
	ref = b;

	Increment(ref);
	LOG(b);//打印8，未改变b的值

	std::cin.get();
}
```

指针，则可以任意变换赋值  

```cpp
	int a = 5;
	int b = 8;

	int* ref = &a;
	*ref = 2;
	ref = &b;
	*ref = 1;

	LOG(a);//2
	LOG(b);//1
```