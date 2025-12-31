---
title: enum
description: enum
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2025-12-30T22:17:14+08:00
lastmod: 2025-12-30T22:17:14+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
- 枚举，其实就是==一组==值  
- 想用整数来表示某些状态，并且给他们命名
- 
```cpp
#include <iostream>

//默认情况下是无符号整型unsigned int
enum Example:unsigned char
{
	//如果不指定的话，第一个
	//为0，然后逐个增加
	//只要没有指定的值，都会根据前一个指定的值逐个增加
	A,B,C
};


int a = 0;
int b = 1;
int c = 2;


int main()
{
	Example value = B;

	//if (value == 1) {
	if (value == B) {
		std::cout << "get" << std::endl;
	}
	std::cin.get();
}
```

## 日志系统改进

```cpp
#include <iostream>

class Log
{
public:
	enum Level
	{
		//这里不能用Error，因为下面有一个同名函数
		LevelError=0, LevelWarning, LevelInfo
	}; 
private:
	//日志实际级别
	//m开头表示类成员变量
	Level m_LogLevel = LevelInfo;
public:
	void SetLevel(Level level)
	{
		m_LogLevel = level;
	}

	//关于字符串指针，后面会讲解
	void Error(const char* message)
	{
		//因为枚举类型是整型，所以
		//这里可以比较
		if (m_LogLevel >= LevelError)
			std::cout << "[ERROR]:" << message << std::endl;
	}

	void Warn(const char* message)
	{
		if (m_LogLevel >= LevelWarning)
			std::cout << "[WARNING]:" << message << std::endl;
	}

	void Info(const char* message)
	{
		if (m_LogLevel >= LevelInfo)
			std::cout << "[INFO]:" << message << std::endl;
	}
};
 
int main()
{
	Log log;
	//警告或更严重的消息会被打印出
	log.SetLevel(Log::LevelWarning);
	log.Warn("Hello!");
	log.Error("Hello!");
	log.Info("Hello!");
	/*
	[WARNING]:Hello!
	[ERROR]:Hello!
	*/

	std::cin.get();
}
```