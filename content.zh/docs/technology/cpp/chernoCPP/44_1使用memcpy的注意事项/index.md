---
title: 44_1使用memcpy的注意事项
description: 44_1使用memcpy的注意事项
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-02-03T10:28:04+08:00
lastmod: 2026-02-03T10:28:04+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 毁掉多态：篡改虚函数表指针 (vptr)

```cpp
#include <iostream>
#include <cstring>

class Entity {
public:
    virtual void SayName() { std::cout << "I am Entity" << std::endl; }
};

class Player : public Entity {
public:
    void SayName() override { std::cout << "I am Player" << std::endl; }
};

void Print(Entity* e) {
    e->SayName(); // 强制程序通过虚表查找
}

int main() {
    Entity base;
    Player p1;

    std::cout << "Before memcpy: ";
    Print(&p1); // 应该输出 I am Player

	//base复制给p1，但是p1的虚函数表却指向的是Entity的
    // 暴力覆盖！把 base 的内存（包含 Entity 的 vptr）强行塞进 p1
    std::memcpy(&p1, &base, sizeof(Entity));

    std::cout << "After memcpy:  ";
    Print(&p1); // 这次，它一定会输出 I am Entity！

    std::cin.get();
}
```

# 内存错位

```cpp
#include <iostream>
#include <cstring>

struct BaseA {
    int a = 111;
};

struct BaseB {
    int b = 222;
};

// Child 同时拥有 a 和 b，继承顺序决定内存顺序，这里先BaseA-->BaseB-->自己的成员
//在内存里，Child 对象是一块连续的砖，布局如下（假设每个 int 占 4 字节）：
// 字节偏移  内容  属于谁
// 0    int a(111)  BaseA的地盘
// 4    int b(222)  BaseB的地盘8int c(3)Child 的地盘
struct Child : public BaseA, public BaseB {
    int c = 333;
};

int main() {
    Child p;
    BaseB sourceB;
    sourceB.b = 999; // 我们准备了一个新的 B，想把它拷进 p 里

    std::cout << "--- 拷贝前 ---" << std::endl;
    std::cout << "p.a = " << p.a << " (BaseA部分)" << std::endl;
    std::cout << "p.b = " << p.b << " (BaseB部分)" << std::endl;

    // --- 致命操作 ---
    // 程序员的意图：把 sourceB 的数据拷贝给 p
    // 程序员认为：p 既然继承了 BaseB，那我就直接拷过去
    std::memcpy(&p, &sourceB, sizeof(BaseB));

    std::cout << "\n--- 运行 memcpy(&p, &sourceB, ...) 后 ---" << std::endl;

    // 错位发生了！
    // 1. p.a 被改成了 999。因为 memcpy 从 p 的开头（BaseA的位置）开始写。
    // 2. p.b 依然是 222。因为它在内存后面，memcpy 根本没写到它。

    std::cout << "p.a = " << p.a << " (被错误覆盖了！)" << std::endl;
    std::cout << "p.b = " << p.b << " (完全没被拷进去！)" << std::endl;

    std::cin.get();

    return 0;
}
```