---
title: 26-29继承_虚函数_接口_可见性
description: 26-29继承_虚函数_接口_可见性
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2025-12-31T18:12:27+08:00
lastmod: 2025-12-31T18:12:27+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 继承
## 例子

```cpp
#include <iostream>

class Entity
{
public:
	float X, Y;
	void Move(float xa, float ya)
	{
		X += xa;
		Y += ya;
	}
};

//public表示子类继承的父类的成员变量/方法，
//最高只能是public。如果是class Player :protected Entity
//则原来父类中的public成员变量变成protected，但是原来的protected
//和private成员变量则不变
class Player :public Entity
{
public:
	const char* Name;

	void PrintName()
	{
		std::cout << Name << std::endl;
	};
};
int main()
{
	//64位系统，Entity两个float，占用了16字节
	std::cout << sizeof(float) << std::endl;//4
	std::cout << sizeof(char*) << std::endl;//8
	std::cout << sizeof(Entity) << std::endl;//4+4=8
	std::cout << sizeof(Player) << std::endl;//4+4+8=16
	Player player;
	player.Move(5, 5);
	player.X = 2;

	std::cin.get();
}
```

多态：如果我现在创建一个独立的函数来打印Entity对象，例如通过访问X和Y变量并将它们打印出来。那我其实也可以将Player对象传递给该函数  


如果在Player中重写方法，就需要维护一个叫做虚函数表(vtable)的东西，会占用额外的内存  

> 1. 对象内部有一个隐藏的 vptr（虚表指针），指向类的 vtable（虚函数表），虚函数表中保存虚函数地址。
> 2. vtable 不在对象里面。vtable 通常是编译器生成的全局静态数据，放在程序的只读数据区（如 .rodata），不是在堆，也不是在栈。对象里面只保存一个 vptr（指针），vptr 指向 vtable。
> 3. 如果调用的是虚函数，编译器不会根据 Animal* 直接确定函数，而是生成通过对象的 vptr 查找 vtable 的代码，运行时根据对象真实类型找到函数；如果调用的是非虚函数，编译器根据指针的==静态类型==直接确定函数地址。

  ==vptr → vtable → 函数地址==  

# 虚函数

## 例子

```cpp
#include <iostream>
#include <string>

class Entity
{
public:
	std::string GetName() { return "Entity"; }
};

class Player :public Entity
{
private :
	std::string m_Name;
public:
	Player(const std::string& name)
		:m_Name(name){}
	std::string GetName() { return m_Name; }
};

int main()
{
	Entity* e = new Entity();
	std::cout << e->GetName() << std::endl;//Entity

	Player* p = new Player("Cherno");
	std::cout << p->GetName() << std::endl;//Cherno

	Entity* entity = p;
	std::cout << entity->GetName() << std::endl;//Entity ??

	std::cin.get();
}
```

你没有告诉 C++ `GetName` 是一个“虚函数”，所以编译器在处理 `Entity* entity` 时，只会根据指针的类型（Entity）来决定调用哪个函数，而不是根据指针指向的实际对象（Player）来决定。(静态联编)
## 例子2

```cpp
#include <iostream>
#include <string>

class Entity
{
public:
	std::string GetName() { return "Entity"; }
};

class Player :public Entity
{
private :
	std::string m_Name;
public:
	Player(const std::string& name)
		:m_Name(name){}
	std::string GetName() { return m_Name; }
};

void PrintName(Entity* entity)
{
	std::cout << entity->GetName() << std::endl;
}

int main()
{
	Entity* e = new Entity();
	PrintName(e);//Entity

	Player* p = new Player("Cherno");
	PrintName(p); //Entity
	 

	std::cin.get();
}
```
如果想要C++以某种方式，通过辨别具体的对象，而调用具体的方法，那么需要加`virtual`关键字  

```cpp
#include <iostream>
#include <string>

class Entity
{
public:
	virtual std::string GetName() { return "Entity"; }
};

class Player :public Entity
{
private :
	std::string m_Name;
public:
	Player(const std::string& name)
		:m_Name(name){}
	//这里override增加了代码的可读性，可以省略
	std::string GetName() override { return m_Name; }
};

void PrintName(Entity* entity)
{
	std::cout << entity->GetName() << std::endl;
}

int main()
{
	Entity* e = new Entity();
	PrintName(e);//Entity

	Player* p = new Player("Cherno");
	PrintName(p); //Cherno
	 

	std::cin.get();
}
```

- 编译器看到virtual关键字，会为该函数生成一个v table(虚函数表)。
- 有代价，1需要额外的内存存储该表，2每次都得额外通过该表确定函数实际映射到哪里，产生额外的性能损失
 

### 拓展-虚函数表

这里我进一步修改了一下main函数中的代码  

```cpp
int main()
{
	Entity* e = new Entity();
	PrintName(e);//Entity

	Entity* p = new Player("Cherno");
	PrintName(p); //Cherno
	 
	std::cin.get();
}
```

### 补充_虚函数表  

![](img/ly-20251231214039872.png)  

#### 1. 虚函数表是什么时候确定的？
**答案：编译时（Compile Time）。**  

编译器在编译阶段发现类中有 `virtual` 函数，就会为每个类创建一个虚函数表。
* **对于 Entity 类**：编译器生成一张表，表里存着 `Entity::GetName` 的内存地址。
* **对于 Player 类**：编译器生成另一张表。由于 `Player` 重写了函数，表里存着的是 `Player::GetName` 的内存地址。
#### 2. 对象里的“指针”是什么时候确定的？
虽然“表”是编译阶段建好的，但对象内部的虚函数表指针（`vptr`）是在**运行时（Runtime）**确定的。

当你执行 `new Entity()` 或 `new Player()` 时：
1. **分配内存**：在堆上申请空间。
2. **构造函数执行**：这是关键！当 `Player` 的构造函数运行时，它会将该对象内部隐藏的 `vptr` 指向 `Player` 类的虚函数表。

---

#### 3. 为什么 PrintName(p) 能打印出 "Cherno"？
即便 `PrintName(Entity* entity)` 函数接收的是基类指针，执行过程如下：

1. **传入指针**：函数拿到了一个内存地址，它只知道这是一个 `Entity` 类型的指针。
2. **查找 vptr**：程序运行到 `entity->GetName()` 时，它会去该地址指向的内存块头部（或尾部，取决于编译器实现）==寻找那个隐藏的 `vptr`==。
3. **跳转 V-Table**：因为这个对象实际上是用 `new Player()` 创建的，它的 `vptr` 指向的是 **Player 的虚函数表**。
4. **执行函数**：程序从 Player 的表里取出 `Player::GetName` 的地址并跳转执行，从而实现了多态。
5. 
#### 总结对照表

| 阶段             | 动作             | 说明                                 |
| :------------- | :------------- | :--------------------------------- |
| **编译阶段**       | **生成 V-Table** | 编译器为每个类确定好“表”里的函数地址==蓝图==。         |
| **运行阶段 (构造时)** | **设置 vptr**    | 对象被创建时，内部指针==指向==所属类的 V-Table 地址。  |
| **运行阶段 (调用时)** | **间接寻址**       | 通过 `vptr` ==找到==正确的函数地址，实现“运行时多态”。 |

## 多态情况下
 
如果一个类可能作为基类 ~~==多态（Polymorphism）==场景~~ ，并且可能通过基类指针删除派生类对象，那么基类析构函数应该声明为 virtual。

当一个基类指针指向一个派生类对象，并执行 delete 操作时，如果析构函数不是虚函数，==编译器==会根据指针的类型（==静态绑定==）来决定调用哪个析构函数。

- 非虚析构函数： ==只会调用基类（Base）==的析构函数，派生类（Derived）特有的成员变量不会被清理。
- 虚析构函数： 会触发==动态绑定（Dynamic Binding）==，先调用派生类的析构函数，再自动调用基类的析构函数。 ~~不是“自动”凭空调用，而是 C++ 析构规则规定：派生类析构完成后，会自动调用基类析构。~~ 

```shell
delete p

↓

发现析构函数是virtual

↓

查对象的vptr

↓

找到Dog的虚函数表

↓

调用Dog::~Dog()

↓

再调用Animal::~Animal()
```

## 【补充】多继承的情况分析

```cpp
class Animal
{
public:
    virtual void eat();
    int age;
};


class Runnable
{
public:
    virtual void run();
    int speed;
};


class Dog : public Animal, public Runnable
{
public:
    void eat() override;
    void run() override;

    int weight;
};
```

### 一个dog对象的内存布局

```shell
Dog对象 dog

//它(Animal vptr)指向的是“Dog针对Animal继承关系生成的虚函数表”。

+----------------+
| Animal vptr    | ----+
+----------------+     |
| Animal::age    |     |
+----------------+     |
                       |
                       v
                 Dog-A vtable

                 +----------------+
                 | Dog::eat       |
                 +----------------+

//它(Runnable vptr)指向的是“Dog针对Runnable继承关系生成的虚函数表”。

+----------------+
| Runnable vptr  | ----+
+----------------+     |
| Runnable::speed|     |
+----------------+     |
                       |
                       v
                 Dog-R vtable

                 +----------------+
                 | Dog::run       |
                 +----------------+


+----------------+
| Dog::weight    |
+----------------+
```

即

```shell
Dog
 |
 +-- Animal vptr --> Dog的Animal虚表
 |
 +-- Runnable vptr --> Dog的Runnable虚表
```

### 多继承下多个虚函数解析

假设：

```C++
class Runnable
{
public:
    virtual void run();
    virtual void stop();
};


class Animal
{
public:
    virtual void eat();
};


class Dog : public Animal, public Runnable
{
public:
    void eat() override;
    void run() override;
    void stop() override;
};
```

#### 1\. Runnable自己的虚函数表

先看 Runnable。

在 Runnable 的世界里：

```C++
Runnable* r;
```

它只知道：

```C++
virtual void run();
virtual void stop();
```

所以它认为虚函数表是： 

```shell
Runnable vtable

[0] Runnable::run
[1] Runnable::stop
```

注意：  

-   第0个槽位对应 `run`
-   第1个槽位对应 `stop`    

这个顺序在编译 Runnable 时就确定了。

#### 2\. Dog继承 Runnable 后

Dog 重写：

```C++
void run() override;
void stop() override;
```

所以 Dog 的 Runnable 部分虚表：

```shell
Dog-Runnable vtable

[0] Dog::run
[1] Dog::stop
```

不是：

```shell
[0] Runnable::run
[1] Runnable::stop
[2] Dog::run
[3] Dog::stop
```

而是==直接替换父类对应槽位==。


#### 3\. 完整 Dog 对象

多继承：

```C++
class Dog : public Animal, public Runnable
```

通常布局类似：

```shell
Dog对象

+----------------+
| Animal vptr    |-----> Dog-Animal vtable
+----------------+
| Animal数据     |
+----------------+


+----------------+
| Runnable vptr  |-----> Dog-Runnable vtable
+----------------+
| Runnable数据   |
+----------------+


+----------------+
| Dog数据        |
+----------------+
```

两个 vtable：

##### Animal方向：

```shell
Dog-Animal vtable

[0] Dog::eat
```

##### Runnable方向：

```shell
Dog-Runnable vtable

[0] Dog::run
[1] Dog::stop
```

#### 4\. 调用时发生什么？

##### 情况1：

```C++
Runnable* r = &dog;

r->run();
```

编译器知道： `r 是 Runnable*`

所以：

它认为：

```shell
Runnable vtable:

[0] = run
[1] = stop
```

生成：`r->vptr[0]()`

运行：  

```shell
Runnable vptr
       |
       v
Dog-Runnable vtable

[0] Dog::run
[1] Dog::stop
```

调用： `Dog::run()`

##### 情况2：

```C++
r->stop();
```

编译器生成：`r->vptr[1]()`

找到： 

```shell
Dog-Runnable vtable

[0] Dog::run
[1] Dog::stop
```

调用： `Dog::stop()`

#### 5\. 如果Dog只重写其中一个呢？

例如：

```C++
class Dog : public Runnable
{
public:
    void run() override;
};
```

没有重写 stop。

那么：

Dog-Runnable vtable：

```shell
[0] Dog::run
[1] Runnable::stop    //注意，这里Runnable::stop并没有被重新，所以还是保留着调用基类的stop地址
```

因为：

-   run 被替换
-   stop 继承父类实现  


#### 6\. 回到你的疑问：为什么一定是第0、第1？

因为：

对于任何 `Runnable*`： `Runnable* p;`

它都遵守同一个协议：  

```shell
Runnable接口：

虚函数0 -> run()
虚函数1 -> stop()
```

这个协议不能改变。

所以任何实现 Runnable 的对象，都必须保证：

```shell
vptr[0] 能找到 run
vptr[1] 能找到 stop
```

Dog只是把地址换成自己的实现：

```shell
vptr[0] -> Dog::run
vptr[1] -> Dog::stop
```

所以总结一句：

> **虚函数表的槽位编号属于基类接口，而不是属于派生类。派生类只是把对应槽位替换成自己的函数地址。**

这也是为什么 C++ 的虚函数能够做到：

```C++
Runnable* p = new Dog();

p->run();
p->stop();
```

即使 `p` 完全不知道自己是 Dog，也能正确调用 Dog 的版本。

# 接口

- 有时候想强制子类自己实现关于某个函数的定义  
- 接口：仅包含类中未实现的方法充当模版
- 纯接口的定义，仅包含纯虚函数(无实现)的抽象类，不能有构造函数，没有数据成员。【C++11后可以有默认实现】
	- 有成员变量，或其他非纯虚函数
- 纯虚函数（pure virtual function） 是 C++ 中一种特殊的虚函数，它表示：基类只规定“必须有这个函数”，但不提供实现，具体怎么做交给派生类。`virtual 返回类型 函数名(参数) = 0;` 
 

## 初步认识

```cpp
#include <iostream>
#include <string>

class Entity
{
public:
	//如果main()中使用 Entity* e = new Entity();，报错
	//'Entity': cannot instantiate abstract class ，这是
	//一个抽象类
	virtual std::string GetName() = 0; //=0表示这个函数没有默认实现，派生类必须实现它。
};

class Player :public Entity
{
private:
	std::string m_Name;
public:
	Player(const std::string& name)
		:m_Name(name) {
	}
	//这里override增加了代码的可读性，可以省略
	std::string GetName() override { return m_Name; }
};

void PrintName(Entity* entity)
{
	std::cout << entity->GetName() << std::endl;
}

int main()
{
	Entity* e = new Player("");
	PrintName(e);//""

	Player* p = new Player("Cherno");
	PrintName(p); //"Cherno"
	
	std::cin.get();
}
```

## 增强

```cpp
#include <iostream>
#include <string>
class Printable
{
public:
	virtual std::string GetClassName() = 0;
};


class Entity :public Printable
{
public:
	virtual std::string GetName()
	{
		return "Entity";
	}

	std::string GetClassName() override
	{
		return "Entity";
	}
};

class Player :public Entity
{
private:
	std::string m_Name;
public:
	Player(const std::string& name)
		:m_Name(name) {
	}
	//这里override增加了代码的可读性，可以省略
	std::string GetName() override { return m_Name; }
	std::string GetClassName() override
	{
		return "Player";
	}
};

void PrintName(Entity* entity)
{
	std::cout << entity->GetName() << std::endl;
}

//================================
class A : public Printable
{
public:
	std::string GetClassName() override { return "A"; }
};
//================================


void Print(Printable* obj)
{
	std::cout << obj->GetClassName() << std::endl;
}


int main()
{
	Entity* e = new Entity();

	Player* p = new Player("Cherno");

	Print(e);//"Entity"
	Print(p);//"Player"
	Print(new A());//"A" 这里直接new会导致内存泄露

	std::cin.get();
}
```

# 可见性

- 可见性指谁可以看见、调用、使用它们(成员变量、成员方法)
- 对性能没影响
- 三个关键字，private，protected，public

## private

```cpp
#include <iostream>
#include <string> 

class Entity 
{ 
//private意味着只有Entity类里面可以直接读取它们，
//(子类不行，其他外部的类[比如main()]也不行)
//例外：友元函数可以读取一个类的private成员
//[友元函数是普通函数，不是类的成员]
private :
	int X, Y;
	void Print() {}
public :
	Entity()
	{
		X = 0;
		Print();
	}
	// 声明 PrintEntity 是 Entity 的友元函数
    friend void PrintEntity(Entity& e);
};

// 注意：这里不是 Entity 的成员函数
// 它是一个普通函数
void PrintEntity(Entity& e)
{
    // 因为它是 friend，所以可以访问 private
    std::cout << e.X << std::endl;
    std::cout << e.Y << std::endl;
}

class Player :public Entity
{ 
public:
	Player()
	{
		//Print();//报错
	}
}; 
 

int main()
{
	Entity e;
	//e.X=2;//报错
	std::cin.get();
}
```

## protected

```cpp
#include <iostream>
#include <string> 

class Entity 
{ 
//protected意味着只有Entity类及其子类里面可以直接读取它们，
//(其他外部的类[比如main()]也不行)
//例外：友元函数可以读取一个类的protected成
// 员[友元函数是普通函数，不是类的成员]
protected :
	int X, Y;
	void Print() {}
public :
	Entity()
	{
		X = 0;
		Print();
	}
	
	// 声明 PrintEntity 是 Entity 的友元函数
    friend void PrintEntity(Entity& e);
};

// 注意：这里不是 Entity 的成员函数
// 它是一个普通函数
void PrintEntity(Entity& e)
{
    // 因为它是 friend，所以可以访问 private
    std::cout << e.X << std::endl;
    std::cout << e.Y << std::endl;
}

class Player :public Entity
{ 
public:
	Player()
	{
		Print();

	}
}; 
 

int main()
{

	Entity e;
	//e.Print();//报错
	std::cin.get();

	std::cin.get();
}
```
## public 

所有地方都可以访问

## 用法

当使用private时，帮助自己/团队其他人员，禁止使用这个数据/方法，说明某些数据仅支持在类内部使用

> 这里举了个例子，假设有个ui功能，里面有数据x,y表示坐标，正常情况下需要使用类方法才能移动该图形。如果x,y不是私有，就有导致坐标被单独修改而图形未移动的奇怪现象

## 友元函数说明

友元函数就是：一个不是类成员的普通函数，被类主动授权后，可以访问这个类的 private 和 protected 成员。  

