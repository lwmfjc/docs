---
title: 48局部静态变量
description: 48局部静态变量
categories:
tags:
date: 2026-02-07T19:38:21+08:00
lastmod: 2026-02-07T19:38:21+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# static的三种用法

## 类外部的 static（作用域限制）

当你把 static 放在全局变量或函数前面时，它的作用是 “私有化” 这个文件。

- 效果：该变量或函数仅在定义它的 .cpp 文件（编译单元） 内可见。
- 为什么要用它？
	- 防止 命名冲突：如果你在 A.cpp 定义了一个 static int x，在 B.cpp 也定义了一个 int x，链接器（Linker）不会报错，因为 A 的 x 是文件私有的。
	- Cherno 的建议：除非你需要变量在多个文件间共享，否则尽量加上 static，让它保持局部化。
## 类内部的 static（成员共享）
当你把 static 放在类成员变量或函数前面时，它的含义变成了 “属于类，而不属于对象”。

### 静态变量

- 效果：无论你创建了多少个该类的对象（实例），这个变量在内存中 只有一份。
- 用法：所有对象共享同一个变量。修改其中一个对象的静态变量，其他对象看到的也是修改后的值。
- 初始化：必须在类外单独进行初始化。

### 静态函数：

- 效果：该函数不需要通过对象（obj.Func()）调用 ~~可以但不推荐，编译器实际上会忽略这个对象，查看obj类型并转化为Class::Func()），可以直接通过类名调用（Class::Func()~~ 。
- 限制：静态函数 没有 this 指针，因此它只能访问类里的其他静态成员，不能访问普通的非静态成员。

## 局部静态变量

局部静态变量是指在==函数内部==声明并带有 static 关键字的变量。

- 生命周期：它的==生命周期贯穿整个程序==。从它第一次被声明开始，直到程序结束它才会消失。

- 作用域：虽然它一直存在，但它==只能在声明它的函数内部被访问==。
# 局部静态变量

声明变量时要考虑两个因素：变量的生命周期 ~~能存在多久~~ ，变量的作用域 ~~能在哪些地方访问这些变量~~   

作用域：如果在函数内声明一个变量则无法在其他函数中访问他  

特点：  
- 初始化时机：它在程序执行到该声明语句时第一次且仅初始化一次。
- 销毁时机：它不会在函数运行结束时销毁，而是在整个程序结束时才会被销毁。

局部静态变量可以放在任何局部范围内，比如 if 语句或 for 循环的大括号里。  
```cpp
#include <iostream>

void Test()
{
    bool condition = true;

    if (condition)
    {
        // 这里的 static 变量不属于整个函数，只属于这个 if 块
        static int i = 0; 
        i++;
        std::cout << i << std::endl;
    }
    // 这里无法访问变量 i，因为它在 if 的作用域之外
}
```
循环内  

```cpp
#include <iostream>

int main() {
    for (int count = 0; count < 5; count++) {
        // 这一行在 count == 0 时执行初始化
        // 在 count == 1, 2, 3, 4 时，编译器会直接“无视” = 0 这个动作
        static int i = 0; 
        
        i++;
        std::cout << "Loop " << count << ": i = " << i << std::endl;
    }
}
```

函数作用域里的静态变量和类作用域的静态变量没太大区别，声明周期一样。唯一的区别是类作用域的那个类里的任何东西都能访问它，而函数内的静态变量则是该函数（某个作用域）的局部变量    

## 不同函数的同名静态变量互不影响

```cpp
#include <iostream>

void Function()
{
	int i = 0;
	i++;
	std::cout << i << std::endl;
}

void Function1()
{
	//首次运行时设置为0，但是
	//之后进来仍然保存上次计算后的值
	static int i = 0;
	i++;
	std::cout << i << std::endl;
}

void Function2()
{
	static int i = 2;
	i+=2;
	std::cout << i << std::endl;
}
int main()
{
	Function();
	Function();
	Function();
	/*
	1
	1
	1
	*/
	Function1();
	Function2();
	Function1();
	Function2();
	Function1();
	Function2();
	/*
	1
	2
	2
	4
	3
	6
	*/
	std::cin.get();
} 
```

## 全局变量

```cpp
#include <iostream>

int i = 0;
void Function()
{
	i++;
	std::cout << i << std::endl;
} 
int main()
{
	Function();
	Function();
	//任何地方任何人都能访问它
	i = 10;
	Function(); 
	std::cin.get();
}
```

# 单例类

## 静态单例实例

不通过静态局部作用域  

```cpp
#include <iostream>

class Singleton
{

private:
	//如果用对象：static Singleton s_Instance; 会在程序启动时（main 函数运行前）就尝试调用构造函数来创建对象。
	//如果用指针：static Singleton* s_Instance; 在程序启动时只是初始化了一个空的“地址盒子”（nullptr），并没有真正创建对象。这给了你 “按需创建”（Lazy Initialization）的机会，即只有当你第一次调用 Get() 时，对象才会被创建。
	static Singleton* s_Instance;

public:
	static Singleton& Get()
	{
		if (!s_Instance)
		{
			s_Instance = new Singleton;
		}
		return *s_Instance;
	}

	void Hello() 
	{
		std::cout << "Hello" << std::endl;
	}
};
Singleton* Singleton::s_Instance = nullptr;

int main()
{
	Singleton::Get().Hello();
	std::cin.get();
}
```

## 本地静态变量

```cpp
#include <iostream>

class Singleton
{ 

public:
	static Singleton& Get()
	{
		//如果没有static，那么instance就是栈上的
		//static：存放在静态存储区中，它和全局变量
		// 待在同一个内存区域。
		
		//静态存储区（逻辑概念）里的变量，最终都会被编译器安排住进“数据段（物理实现）”这栋大楼里。数据段包括已初始化静态存储、未初始化静态存储、只读静态存储
		//只有在第一次调用时返回instance实例，之后每次
		//调用都会只返回那个已有实例
		static Singleton instance; 
		return instance;
	}

	//返回的是引用，但是instance在
	//函数退出后就从栈上消失了，这段代码
	//有安全隐患
	static Singleton& Get1()
	{ 
		Singleton instance;
		return instance;
	}

	void Hello() 
	{
		std::cout << "Hello" << std::endl;
	}
}; 

int main()
{
	Singleton::Get().Hello();
	std::cin.get();
}
```

# 其他用途

在程序里有时得调用静态初始化函数，从而创建所有对象，就能用静态获取方法了  

```cpp
#include <iostream>
#include <string>

class LogSystem {
private:
    static LogSystem* s_Instance; // 静态指针，用来指向那个唯一的对象
    std::string m_Status;

    LogSystem() { m_Status = "已就绪"; } // 私有构造函数

public:
    // 1. 静态初始化函数：负责把对象创建出来
    static void Init() {
        if (!s_Instance) {
            s_Instance = new LogSystem();
            std::cout << "系统：日志单例已静态初始化完成。\n";
        }
    }

    // 2. 静态获取方法：全程序任何地方都能拿
    static LogSystem& Get() {
        return *s_Instance;
    }

    void Print(const std::string& msg) {
        std::cout << "[" << m_Status << "] " << msg << std::endl;
    }
};

// 在类外定义静态指针
LogSystem* LogSystem::s_Instance = nullptr;

int main() {
    // 【关键点】：在程序刚开始时，调用静态初始化函数
    // 这一步“创建了所有（必要的）对象”
    LogSystem::Init(); 

    // 之后在程序的任何角落，只需要用“静态获取方法”即可
    LogSystem::Get().Print("这是一条日志。");

    return 0;
}
```

如上，就是说可以利用静态初始化函数，提前把大部分需要的对象提前创建出来  

