---
title: 40运算符和运算符重载
description: 40运算符和运算符重载
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-01-11T16:24:51+08:00
lastmod: 2026-01-11T16:24:51+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 重载运算符`+`

## 方法1

```cpp
#include <iostream>
#include <string>   

struct Vector2
{
	float x, y;

	Vector2(float x, float y)
		:x(x), y(y) {
	}

	Vector2 Add(const Vector2& other) const
	{
		return Vector2(x + other.x, y + other.y);
	}

	Vector2 operator+(const Vector2& other) const
	{
		return Add(other);
	}

	Vector2 Multiply(const Vector2& other) const
	{
		return Vector2(x * other.x, y * other.y);
	}

};

int main()
{
	Vector2 position(4.0f, 4.0f);
	Vector2 speed(0.5f, 1.5f);
	Vector2 powerup(0.5f, 1.5f);

	Vector2 result1 = position.Add(speed.Multiply(powerup));
	Vector2 result2 = position + speed;// *powerup;

	std::cin.get();
}
```

## 方法2

```cpp
#include <iostream>
#include <string>   

struct Vector2
{
	float x, y;

	Vector2(float x, float y)
		:x(x), y(y) {
	}

	Vector2 Add(const Vector2& other) const
	{
		//this是指向自身的一个指针
		//return *this + other;

		//或者
		return operator+(other);
	}

	Vector2 operator+(const Vector2& other) const
	{
		return Vector2(x + other.x, y + other.y);
	}

	Vector2 Multiply(const Vector2& other) const
	{
		return Vector2(x * other.x, y * other.y);
	}

};

int main()
{
	Vector2 position(4.0f, 4.0f);
	Vector2 speed(0.5f, 1.5f);
	Vector2 powerup(0.5f, 1.5f);

	Vector2 result1 = position.Add(speed.Multiply(powerup));
	Vector2 result2 = position + speed;// *powerup;



	std::cin.get();
}
```

# 重载运算符 `*` 及 `==`

```cpp
#include <iostream>
#include <string>   

struct Vector2
{
	float x, y;

	Vector2(float x, float y)
		:x(x), y(y) {
	}

	Vector2 Add(const Vector2& other) const
	{
		return Vector2(x + other.x, y + other.y);
	}

	Vector2 operator+(const Vector2& other) const
	{
		return Add(other);
	}

	Vector2 Multiply(const Vector2& other) const
	{
		return Vector2(x * other.x, y * other.y);
	}

	Vector2 operator*(const Vector2& other) const
	{
		return Multiply(other);
	}

	bool operator==(const Vector2& other) const
	{
		return x == other.x && y == other.y;
	}

	bool operator!=(const Vector2& other) const
	{
		//return !(*this == other);
		//或者
		return !operator==(other);
	}

};

std::ostream& operator<<(std::ostream& stream, const Vector2& other)
{
	stream << other.x << "," << other.y;
	return stream;
}

int main()
{
	Vector2 position(4.0f, 4.0f);
	Vector2 speed(0.5f, 1.5f);
	Vector2 powerup(0.5f, 1.5f);

	Vector2 result1 = position.Add(speed.Multiply(powerup));
	Vector2 result2 = position + speed * powerup; 

	std::cout << result1 << std::endl;
	std::cout << result2 << std::endl;

	if (result1 == result2)
		std::cout << "---equals---" << std::endl;

	std::cin.get();
}
```

运算符重载本质上就是函数。虽然你可以自定义运算符的行为（即函数体里写什么），但你不能改变 C++ 语言定义的运算符规则，包括：
- ==优先级==（Precedence）：例如 * 永远比 + 先执行。
- 结合性（Associativity）：决定了同级运算符是从左往右还是从右往左计算。
- 操作数数量：你不能把一元运算符变成二元运算符。

