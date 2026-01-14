---
title: 43智能指针
description: 43智能指针
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-01-12T22:13:59+08:00
lastmod: 2026-01-12T22:13:59+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
智能指针，是真实原始指针被包装。使用智能指针时，将调用new并分配给你内存，这块内存在某些时候会自动释放  

# unique pointer 唯一指针

在一个作用域内，同一个原始指针只能被一个 unique_ptr 管理。它禁止拷贝，这意味着你不能通过赋值来增加它的引用，只能使用 `std::move()` 将所有权从一个指针转移给另一个。  

## 转让所有权-附加知识点

```cpp
#include <iostream>
#include <memory>
class Entity {};
int main() {
    // 1. 创建第一个 unique_ptr
    std::unique_ptr<Entity> entity = std::make_unique<Entity>();

    // 2. 使用 std::move 转移所有权
    // 此时，entity 原有的内存所有权交给了 e2
    std::unique_ptr<Entity> e2 = std::move(entity);

    // 3. 检查状态
    if (entity == nullptr) {
        std::cout << "entity 现在是空的 (nullptr)" << std::endl;
    }

    if (e2 != nullptr) {
        std::cout << "e2 现在拥有 Entity 的所有权" << std::endl;
    }

    std::cin.get();
    return 0;
} // e2 在这里离开作用域，Entity 被自动销毁
```

## 示例-主要知识点

```cpp
#include <iostream>  
#include <string>
#include <memory>

class Entity
{
public:

	//constructor-构造函数
	Entity()
	{
		std::cout << "Created Entity!" << std::endl;
	}


	//destructor-析构函数
	~Entity()
	{
		std::cout << "Destroyed Entity!" << std::endl;
	}

	void Print()
	{
		std::cout << "hello" << std::endl;
	}

};

int main()
{
	std::cout << "start--" << std::endl;
	{
		//不允许，禁止隐式转换
		//std::unique_ptr<Entity> entity =new Entity();
		
		//允许,直接调用构造函数，但是不建议
		//如果创建完原始对象后发生了异常，没有来得及将它放到智能指针对象
		//会导致不释放指针指向内存，导致内存泄漏
		//std::unique_ptr<Entity> entity(new Entity());
		
		//不会有这问题，因为std::make_unique保证了创建对象和将其
		// 放入智能指针是一个原子操作==，中间不会被其他逻辑插入，因
		// 此它是异常安全的。
		std::unique_ptr<Entity> entity = std::make_unique<Entity>();

		entity->Print();

		std::unique_ptr<Entity> e2 = std::move(entity);//允许
		//std::unique_ptr<Entity> e3 = entity;//不允许，编译报错
		/*查看源码
		* 复制构造函数和赋值操作符被删除
			unique_ptr(const unique_ptr&)            = delete;
			unique_ptr& operator=(const unique_ptr&) = delete;		
		*/

	}
	std::cout << "end--" << std::endl;
	std::cin.get();
}
/*
start--
Created Entity!
hello
Destroyed Entity!
end--
*/
```

不允许`std::unique_ptr<Entity> entity =new Entity();`  因为禁止隐式转换  

![](img/ly-20260112224640629.png)  

### 为什么使用`std::make_unique`

异常安全性（最核心的区别）
在复杂的表达式中，`std::unique_ptr<Entity> entity(new Entity());` 写法可能会导致内存泄漏。

假设你有这样一个函数： `void Function(std::unique_ptr<Entity> e, void(*DoSomething)())`

如果你这样调用它： `Function(std::unique_ptr<Entity>(new Entity()), PossibleExceptionFunc());`

风险： C++ 标准并不规定参数的计算顺序。如果编译器先执行了 `new Entity()`，接着执行了 `PossibleExceptionFunc()`，而后者抛出了异常，那么此时 unique_ptr 还没来得及构造。

后果： 刚刚 new 出来的内存就再也没有人能释放它了，导致内存泄漏。

解决： `std::make_unique` ==保证了创建对象和将其放入智能指针是一个原子操作==，中间不会被其他逻辑插入，因此它是异常安全的。  

# share pointer 共享指针

- unique_ptr： 内部只包含一个原始指针。它不维护任何额外的数据。在编译优化后，它的机器码和原始指针几乎一模一样。
- shared_ptr： 必须维护一个控制块 (Control Block)。这个控制块包含：==引用计数（Reference Count）==、弱引用计数（Weak Count）、其他元数据（如自定义删除器）每次拷贝或销毁shared_ptr，都要去更新这个计数。 当没有任何引用指向它时，才会delete原对象  

共享指针的工作原理，是通过引用计数，引用计数是一种跟踪你有==多少个引用==指向那个指针，当引用计数达到0时，指针被delete  

## 例子

创建一个共享指针，然后创建另一个共享指针并复制引用，现在引用计数是两个。当第一个共享指针消失后计数减一，当最后一个共享指针消失后计数为零，引用消失，内存被释放  


```cpp
#include <iostream>  
#include <string>
#include <memory>

class Entity
{
public:

	//constructor-构造函数
	Entity()
	{
		std::cout << "Created Entity!" << std::endl;
	}


	//destructor-析构函数
	~Entity()
	{
		std::cout << "Destroyed Entity!" << std::endl;
	}

	void Print()
	{
		std::cout << "hello" << std::endl;
	}

};

int main()
{
	//这里e1不增加引用计数，所以
	std::weak_ptr<Entity> e1;
	std::cout << "start--" << std::endl;
	{
		std::cout << "start0--" << std::endl;
		std::shared_ptr<Entity> e0;
		{
			std::cout << "start1--" << std::endl;
			std::shared_ptr<Entity> sharedEntity = std::make_shared<Entity>();
			e1= sharedEntity;
			e0 = sharedEntity;
			std::cout << "end1--" << std::endl;
		}
		//至此sharedEntity已经被回收，但是e0还在
		std::cout << "end0--" << std::endl;
	}
	//至此e0已经被回收，所有的指向Entity对象的引用都被回收了，e1虽然没有被回收但是它不增加引用计数，所以Entity对象被回收
	std::cout << "end--" << std::endl;
	std::cin.get();
}
/* end0打印后，Entity对象才被回收
start--
start0--
start1--
Created Entity!
end1--
end0--
Destroyed Entity!
end--
*/
```

# weak指针的作用-补充

## 循环引用的问题

```cpp
#include <memory>
#include <iostream>

struct B; // 前置声明

struct A {
    A()
    {
        std::cout << "堆内存a1 创建了~" << std::endl;
    }
    std::shared_ptr<B> ptrB;
    ~A() { std::cout << "堆内存a1 销毁了\n"; }
};

struct B {
    B()
    {
        std::cout << "堆内存b1 创建了~" << std::endl;
    }
    std::shared_ptr<A> ptrA;
    ~B() { std::cout << "堆内存b1 销毁了\n"; }
};

void test() {
    std::cout << "---1" << std::endl;
    auto a = std::make_shared<A>();//假设引用了堆内存a1
    std::cout << "---2" << std::endl;
    auto b = std::make_shared<B>();//假设引用了堆内存b1
    a->ptrB = b; // a.ptrB 又引用 b1
    b->ptrA = a; // b.ptrA 又引用 a1

    //打印目前引用计数
    std::cout << "a1被引用次数:" << a.use_count() << std::endl;
    std::cout << "a1被引用次数:" << b->ptrA.use_count() << std::endl;
    std::cout << "b1被引用次数:" << b.use_count() << std::endl;
    std::cout << "b1被引用次数:" << a->ptrB.use_count() << std::endl;

}//如果struct B的成员ptrA为share_ptr，则：函数结束，a 和 b 本该被销毁，但由于互相引用，a，b的析构函数执行了，但是a1，b1的析构函数永远不会执行！因为有多个引用指向a1，b1

int main()
{
    test(); 
    //这里结束后 栈内存a，b都销毁了
    std::cout << "函数调用结束" << std::endl;
    std::cin.get();
    return 0;
}
/*
---1
堆内存a1 创建了~
---2
堆内存b1 创建了~
a1被引用次数:2
a1被引用次数:2
b1被引用次数:2
b1被引用次数:2
函数调用结束
//这里函数调用结束后 栈内存a，b都销毁了
*/
```

这里有个地方要注意  
1. 局部变量销毁了，意味着什么？
在 test() 函数结束时，栈上的局部变量 a 和 b 会自动失效。
- 当 a 销毁时，它会调用析构函数(不是对象A的析构函数，是`std::shared_ptr<Entity>` 的析构函数)，动作是：“让它指向的 A 对象的引用计数减 1”。
- 当 b 销毁时，它会调用析构函数(不是对象B的析构函数，是`std::shared_ptr<Entity>`的析构函数 )，动作是：“让它指向的 B 对象的引用计数减 1”。
1. 关键在于计数没有归零
- A 对象最初计数是 2。a 销毁后，计数减 1，还剩下 1（因为 b->ptrA 还指着它）。
- B 对象最初计数是 2。b 销毁后，计数减 1，还剩下 1（因为 a->ptrB 还指着它）。

总结：
- 局部变量（栈）：确实销毁了。
- 对象实体（堆）：因为计数没归零，被漏掉了。

### std::shared_ptr 如何在计数归零时触发 delete

简单来说： 每一个 shared_ptr 析构时都会“问”一下堆里的控制块：“我是最后一个吗？”。如果是，它就负责“收尸”（执行 delete）；如果不是，它就安静地走开。即先触发shared_ptr的析构函数，再决定是否delete堆内存(即堆内存对象的析构函数)

### 解决办法

只修改了`struct B `中的某一行，下面有注释

```cpp
#include <memory>
#include <iostream>

struct B; // 前置声明

struct A {
    A()
    {
        std::cout << "堆内存a1 创建了~" << std::endl;
    }
    std::shared_ptr<B> ptrB;
    ~A() { std::cout << "堆内存a1 销毁了\n"; }
};

struct B {
    B()
    {
        std::cout << "堆内存b1 创建了~" << std::endl;
    }
    //std::shared_ptr<A> ptrA;//删除并添加下一行!!
    std::weak_ptr<A> ptrA;//这里仅仅修改了这行!!

    ~B() { std::cout << "堆内存b1 销毁了\n"; }
};

void test() {
    std::cout << "---1" << std::endl;
    auto a = std::make_shared<A>();//假设引用了堆内存a1
    std::cout << "---2" << std::endl;
    auto b = std::make_shared<B>();//假设引用了堆内存b1
    a->ptrB = b; // a.ptrB 又引用 b1
    b->ptrA = a; // b.ptrA 又引用 a1

    //打印目前引用计数
    std::cout << "a1被引用次数:" << a.use_count() << std::endl;
    std::cout << "a1被引用次数:" << b->ptrA.use_count() << std::endl;
    std::cout << "b1被引用次数:" << b.use_count() << std::endl;
    std::cout << "b1被引用次数:" << a->ptrB.use_count() << std::endl;

}//如果struct B的成员ptrA为share_ptr，则：函数结束，a 和 b 本该被销毁，但由于互相引用，a，b的析构函数执行了，但是a1，b1的析构函数永远不会执行！因为有多个引用指向a1，b1

int main()
{
    test();
    //这里结束后 栈内存a，b都销毁了
    std::cout << "函数调用结束" << std::endl;
    std::cin.get();
    return 0;
}
/*
---1
堆内存a1 创建了~
---2
堆内存b1 创建了~
a1被引用次数:1
a1被引用次数:1
b1被引用次数:2
b1被引用次数:2
堆内存a1 销毁了
堆内存b1 销毁了
函数调用结束
*/
```

### 分析堆内存a，b；及栈内存a1，b1的销毁顺序

当 test() 函数运行到结束的大括号 } 时，栈内存开始清理：

1. 栈内存 b 销毁：它是最后定义的，所以最先析构。
	- 此时 b1 的强引用计数从 2 降为 1（因为 a1->ptrB 还指着它）。
	- 结果：堆内存 b1 此时不执行析构函数。

2. 栈内存 a 销毁：它是第一个定义的，最后析构。
	- 此时 a1 的强引用计数从 1 降为 0（因为 b1->ptrA 是 weak_ptr，不计入强引用）。
	- 结果：由于计数归零，堆内存 a1 开始执行析构函数。

3. 堆内存 a1 销毁过程：
	- 在 a1 的析构过程中，它的成员变量 ptrB（是一个 shared_ptr）也会随之销毁。
	- ptrB 销毁导致 b1 的强引用计数从 1 降为 0。
	- 结果：由于计数归零，堆内存 b1 紧接着执行析构函数。

#### 解释“在 a1 的析构过程中，它的成员变量 ptrB（是一个 shared_ptr）也会随之销毁。”

析构函数的“幕后工作”

在 C++ 中，一个类的析构过程分为两步，这是由编译器自动完成的：

- 执行析构函数体：也就是你写的 { std::cout << "..." << std::endl; } 里面的代码。
- 执行成员变量的析构（自动发生）：在你的函数体执行完后，编译器会自动按照声明顺序的逆序，调用所有成员变量的析构函数。

逻辑流程如下：

```C++
~A() {
    // 1. 先执行你写的代码
    std::cout << "堆内存a1 销毁了\n";

    // 2. 编译器暗中帮你执行：
    // ptrB.~shared_ptr<B>(); 
}
```

附上struct A的定义  

```cpp
struct A {
    A()
    {
        std::cout << "堆内存a1 创建了~" << std::endl;
    }
    std::shared_ptr<B> ptrB;
    ~A() { std::cout << "堆内存a1 销毁了\n"; }
};
```

## 作为观察者存在

```cpp
#include <iostream>
#include <memory>
class Entity
{
public:

	//constructor-构造函数
	Entity()
	{
		std::cout << "Created Entity!" << std::endl;
	}


	//destructor-析构函数
	~Entity()
	{
		std::cout << "Destroyed Entity!" << std::endl;
	}

	void Print()
	{
		std::cout << "hello" << std::endl;
	}

};
int main() {
    std::weak_ptr<Entity> observer;

    {
        std::shared_ptr<Entity> entity = std::make_shared<Entity>();
        observer = entity; // observer 记住了这个 entity

        // 此时 entity 还在
        if (auto locked = observer.lock()) { // lock() 尝试转成 shared_ptr
            std::cout << "对象还在，正在调用 Print...\n";
            locked->Print();
        }
    } // 出了这个大括号，entity 被销毁了

    // 此时 entity 已经不在了
    if (auto locked = observer.lock()) {
        locked->Print();
    }
    else {
        std::cout << "对象已经销毁了，无法调用！\n";
    }
    std::cin.get();
    return 0;
}
/*
Created Entity!
对象还在，正在调用 Print...
hello
Destroyed Entity!
对象已经销毁了，无法调用！
*/
```