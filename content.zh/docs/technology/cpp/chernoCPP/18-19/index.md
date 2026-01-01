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
- 结构的成员默认是公共的

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
- 需要用到继承时，集成struct编译器会给警告。不过它的继承机制与 class 完全相同。主要区别在于默认访问控制权限。

# 编写一个类

