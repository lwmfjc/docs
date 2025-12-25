---
title: 16指针
description: 16指针
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2025-12-23T12:38:06+08:00
lastmod: 2025-12-23T12:38:06+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
***指针***

当你写一个程序的时候，你启动他，整个应用程序就会加载到内存，告诉计算机根据代码执行的操作都被加载到内存中，这是cpu实际访问你写的变量的方式。  

指针，是一个==存储内存地址==的*数字*  

我们需要从内存中，读取或者写入东西，指针，就是内存的地址  

==忘记指针的类型==  

# 例子

`void*` 表示我们不关心地址指向的实际数据是什么类型的

```cpp
#include <iostream>
#define LOG(x) std::cout << x << std::endl

int main(){
	void* ptr=0;//0，表示这是一个无效指针
	//void* ptr=NULL;// NULL是一个# define NULL 0，其实也是0
	//void* ptr=nullptr;// c++11引入的
	std::cin.get();
}
```

> void func(int);
  void func(void*);
 func(0);//调用func(int)，而不是 func(void*)，存在歧义
 >func(nullptr);// 明确调用 func(void*)


