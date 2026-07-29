---
title: 18-19类_基础
description: 18-19类_基础
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2025-12-30T00:08:25+08:00
lastmod: 2025-12-30T00:08:25+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 类_基础知识
类：将数据和功能整合在一起  

## 类定义及函数
```cpp
//类定义
class Player
{
	//默认是私有的
	//int x, y;
//这里的public包括了speed这个成员
public:
	int x, y;
	int speed;
};

//函数
void Move(Player& player, int xa, int ya)
{
	player.x += xa*player.speed;
	player.y += ya*player.speed;
}

int main()
{
	//player:对象
	//创建(实例化)一个对象
	Player player;
	player.x = 1;
	player.y = 2;
	player.speed = 2;
	Move(player, 1, -1);
	LOG(player.x);//3
	LOG(player.y);//0
}
```

## 类定义及方法

```cpp
//类定义
class Player
{
	//默认是私有的
	//int x, y;
//这里的public包括了speed和Move这个成员
public:
	int x, y;
	int speed;
	//方法
	void Move( int xa, int ya)
	{
		x += xa * speed;
		y += ya * speed;
	}
};



int main()
{
	//player:对象
	//创建(实例化)一个对象
	Player player;
	player.x = 1;
	player.y = 2;
	player.speed = 2;
	player.Move( 1, -1);
	LOG(player.x);//3
	LOG(player.y);//0
}
```

# C++中结构和类的区别

- 类的默认成员是私有的
- 类的默认继承权限是私有的

- 结构的成员默认是公共的
- 结构的默认继承权限是公共的

| 区别     | struct | class   |
| ------ | ------ | ------- |
| 默认成员权限 | public | private |
| 默认继承权限 | public | private |
| 成员函数   | 支持     | 支持      |
| 构造函数   | 支持     | 支持      |
| 析构函数   | 支持     | 支持      |
| 虚函数    | 支持     | 支持      |
| 继承     | 支持     | 支持      |
| 模板     | 支持     | 支持      |
| 友元     | 支持     | 支持      |
| 运算符重载  | 支持     | 支持      |


```cpp
//结构定义
struct Player
{
	//默认是public的
	int x, y;
	int speed;
	//方法
	void Move( int xa, int ya)
	{
		x += xa * speed;
		y += ya * speed;
	}
};



int main()
{
	Player player;
	player.x = 1;
	player.y = 2;
	player.speed = 2;
	player.Move( 1, -1);
	LOG(player.x);//3
	LOG(player.y);//0
}
```

C++中还是用struct是为了与C保持向后兼容性，但也可以用`#define struct class`来保证，但是可见性有点问题（默认的public在class中是private）  

- 使用普通数据类型时，没有很多方法，用struct
- struct 可以继承，且继承机制与 class 完全相同。区别主要在于默认访问控制：struct 默认成员为 public，默认继承为 public；class 默认成员为 private，默认继承为 private。某些代码规范可能不推荐 struct 用于复杂继承，但编译器不会因此警告。

# 编写一个类

