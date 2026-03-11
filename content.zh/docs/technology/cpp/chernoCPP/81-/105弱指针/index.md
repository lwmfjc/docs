---
title: 105弱指针
description: 105弱指针
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-03-11T21:30:15+08:00
lastmod: 2026-03-11T21:30:15+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 共享指针与唯一指针例子

```cpp
#ifdef LY_EP105
#include <iostream>
#include <memory>

class Entity {
public:
	Entity() { std::cout << "Entity Created" << std::endl; }
	~Entity() { std::cout << "Entity Destroyed" << std::endl; }
};

int main() {
	// --- unique_ptr 示例 ---
	{
		std::unique_ptr<Entity> e1 = std::make_unique<Entity>();
		// std::unique_ptr<Entity> e2 = e1; // 错误！禁止复制
		std::unique_ptr<Entity> e2 = std::move(e1); // 允许移动所有权，e1 现在为空
	} // e2 离开作用域，Entity 在这里被销毁

	std::cout << "-----------------" << std::endl;

	{
		// --- shared_ptr 示例 ---
		std::shared_ptr<Entity> sharedOuter;
		{
			//std::shared_ptr对象实例内部有一个引用计数，简单记录有多少个共享指针指向内部Entity对象的实例
			std::shared_ptr<Entity> sharedInner = std::make_shared<Entity>();

			sharedOuter = sharedInner; // 允许复制（拷贝赋值函数），引用计数变为 2
			std::cout << "Inner scope ending1..." << std::endl;
			std::shared_ptr<Entity> sharedInner1 = std::move(sharedOuter);//这里把sharedInner的所有权移走了，计数减一，但是本身又导致计数加一，所以目前是2 

			std::cout << "Inner scope ending2..." << std::endl;
		} // sharedInner1 离开作用域，sharedOuter所有权被移走，所以没有任何共享指针指向Entity了，  Entity 被销毁 

		std::cout << "Outer scope still holds Entity？" << std::endl;
	} //作用域结束，sharedOuter 离开作用域，Entity 最终在这里被销毁

	std::cin.get();
}
/*
Entity Created
Entity Destroyed
-----------------
Entity Created
Inner scope ending1...
Inner scope ending2...
Entity Destroyed
Outer scope still holds Entity？
*/
#endif
```

共享指针、强引用，能防止对象销毁，也被称作具名引用。即他们对一个对象各自都拥有所有权  

# 共享指针例子
## 共享指针例子

```cpp
#ifdef LY_EP105
#include <iostream>
#include <memory>

struct Object
{

	~Object()
	{
		std::cout << "object destroyed!" << std::endl;
	}
};

struct Manager
{
	std::shared_ptr<Object> shareObj2;
};

int main() {
	{
		Manager manager;

		{
			std::shared_ptr<Object> shareObj1 = std::make_shared<Object>();

			manager.shareObj2 = shareObj1;

		}//代码块结束时，shareObj1内部的Object实例对象并没有销毁

		std::cout << "obj still alive?" << std::endl;
	}
	//now obj still die,打印 object destroyed!

	std::cout << "obj still die?" << std::endl;;
	std::cin.get();
}
#endif
/*
obj still alive?
object destroyed!
obj still die?
*/
```

## 强引用例子

```cpp
#ifdef LY_EP105
#include <iostream>
#include <memory>

struct Object
{

	~Object()
	{
		std::cout << "object destroyed!" << std::endl;
	}
};

struct Manager
{
	//强引用，没有共享指针对象
	Object* shareObj2;
};

int main() {
	{
		Manager manager;

		{
			std::shared_ptr<Object> shareObj1 = std::make_shared<Object>();

			//没有阻止作用域外shareObj1内部实例销毁
			manager.shareObj2 = shareObj1.get();

		}//代码块结束时，shareObj1内部的Object实例对象被销毁

		std::cout << "obj still alive?" << (manager.shareObj2 == nullptr ? "true" : "false") << std::endl; //这里答案是false，即不是nullptr，但是shareObj2指向的对象(shareObje1内部的Object实例)早就销毁了
	}

	std::cout << "obj still die?" << std::endl;;
	std::cin.get();
}
/*
object destroyed!
obj still alive?false
obj still die?
*/
#endif 
```

指向的对象已经销毁但是指针却不为空  

# 什么是 `std::weak_ptr`？ 

`std::weak_ptr` 是一种不增加引用计数的智能指针。它必须与 `std::shared_ptr` 配合使用。当你将一个 `shared_ptr` 赋值给 `weak_ptr` 时，==它会指向相同的人内存，但不会增加该内存的“所有权”计数（reference count）==。

# 为什么需要它？（解决循环引用） 

- ==循环引用问题：== 如果两个类互相持有对方的 `shared_ptr`，它们的引用计数永远不会归零，导致内存泄漏。
- ==解决方案：== 将其中一个改为 `weak_ptr`。这样，当其中一个对象被销毁时，由于 `weak_ptr` 不计入引用计数，另一个对象也能被正确释放。

# 如何检查对象是否还存在？ 

由于 `weak_ptr` 不保证它指向的对象一定有效，在使用前必须检查。

- ==`expired()` 方法：== 返回一个布尔值，检查底层对象是否已被销毁。 
- ==`lock()` 方法：== 这是最常用的安全访问方式。它会返回一个 `std::shared_ptr`。如果对象还活着，你会得到一个有效的 `shared_ptr`（此时引用计数临时加 1）；如果对象已销毁，则返回一个空的 `shared_ptr`。 

```cpp
#ifdef LY_EP105
#include <iostream>
#include <memory>

struct Object
{

	~Object()
	{
		std::cout << "object destroyed!" << std::endl;
	}
};

struct Manager
{
	//弱引用，可以用来共享指针对象但是不增加计数
	std::weak_ptr<Object> shareObj2;
};

int main() {
	{
		Manager manager;

		{
			std::shared_ptr<Object> shareObj1 = std::make_shared<Object>();

			//没有阻止作用域外shareObj1内部实例销毁
			//弱指针有一个接受共享指针的构造器
			manager.shareObj2 = shareObj1;

		}//代码块结束时，shareObj1内部的Object实例对象被销毁

		std::cout << "obj still alive?" << (manager.shareObj2.expired() ? "false" : "true") << std::endl; //这里答案是true，即shareObj2指向的对象(shareObje1内部的Object实例)早就销毁了

		//阻止了一种情况，就是检查后执行完//1之后，对象在其他线程中被
			//析构了
		//1. 由于 lock() 返回的是一个 shared_ptr（即代码中的 obj），根据 shared_ptr 的规则：
			//只要 obj 还在生命周期内（即在 if 分支的大括号 {} 里面），强引用计数至少为 1。
			//即使在执行 //1 或 //2 的瞬间，另一个线程销毁了 manager 里的原始 shared_ptr，对象也不会被析构。
		//2. 内存的释放被推迟到了 obj 离开作用域（大括号结束）的那一刻。
		if (auto obj = manager.shareObj2.lock())
		{

			//1
			//2
			
		}
		
		//检查是否存活
		if (manager.shareObj2.expired())
		{

		}

		//检查引用计数
		if (manager.shareObj2.use_count() == 0)
		{

		}
	}

	std::cout << "obj still die?" << std::endl;;
	std::cin.get();
}
/*
object destroyed!
obj still alive?true
obj still die?
*/
#endif 
```

# 点评

- 唯一指针没有什么开销，共享指针会有开销

# 实际应用场景 

- ==缓存（Caching）：== 你可能想保存一个指向对象的指针，但不希望因为这个缓存而强制该对象一直留在内存中。
- ==观察者模式（Observer Pattern）：== 观察者可以持有被观察对象的 `weak_ptr`，这样被观察者被销毁时，观察者不会持有“僵尸”引用。

