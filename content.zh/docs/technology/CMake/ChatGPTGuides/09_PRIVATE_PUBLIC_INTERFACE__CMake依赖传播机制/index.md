---
title: 09_PRIVATE_PUBLIC_INTERFACE__CMake依赖传播机制
description: 09_PRIVATE_PUBLIC_INTERFACE__CMake依赖传播机制
categories:
  - 学习
tags:
  - CMake
  - ChatGPTGuides
date: 2026-09-10T21:56:25+08:00
lastmod: 2026-09-10T21:56:25+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
你现在已经进入现代 CMake 的核心部分。

接下来：

***第9章：PRIVATE / PUBLIC / INTERFACE —— CMake依赖传播机制***

这一章非常重要。

你以后看：

* ROS2 CMakeLists.txt
* Qt项目
* OpenCV项目
* 大型C++项目

一定会看到：

```cmake
target_link_libraries(
    xxx
    PRIVATE
    yyy
)
```

或者：

```cmake
target_include_directories(
    xxx
    PUBLIC
    include
)
```

很多初学者知道语法，但是不知道为什么。

---

# 9.1 为什么需要 PRIVATE / PUBLIC / INTERFACE？

先回顾：

第8章：

```cmake
target_link_libraries(
    robot
    motor
)
```

表示：

```text
robot

依赖

motor
```

但是有一个问题：

如果：

```text
A依赖B
B依赖C
```

那么：

```text
A需要知道C吗？
```

这就是 PRIVATE / PUBLIC / INTERFACE 解决的问题。

---

# 9.2 一个实际例子

假设：

我们有三个模块：

```text
app

motor

hardware
```

关系：

```text
app
 |
 |
依赖
 |
 ↓
motor
 |
 |
依赖
 |
 ↓
hardware
```

代码：

```cpp
// motor.cpp

#include "hardware.h"


void motor_run()
{
    gpio_write();
}
```

motor使用hardware。

---

现在：

app使用motor：

```cpp
#include "motor.h"

int main()
{
    motor_run();
}
```

问题：

app需要知道hardware吗？

答案：

不一定。

因为：

app只调用：

```cpp
motor_run()
```

它不知道：

底层是不是：

```text
GPIO
CAN
UART
SPI
```

---

这就是 PRIVATE。

---

# 9.3 PRIVATE：私有依赖

写：

```cmake
target_link_libraries(
    motor

    PRIVATE

    hardware
)
```

意思：

```text
motor需要hardware

但是：

这是motor自己的内部实现

不要暴露给别人
```

关系：

```text
app

 |
 ↓

motor

 |
 ↓

hardware
```

但是：

app看不到hardware。 ~~就是不让依赖motor的target，知道hardware~~ 

---

类似：

Java：

你的类：

```java
class Motor {

    private GPIO gpio;

}
```

外部：

```java
Motor m = new Motor();

m.run();
```

用户不需要知道：

里面用了GPIO。

---

# 9.4 PUBLIC：公开依赖

现在换一种情况。

比如：

你写一个数学库：

```text
math
```

里面：

```cpp
#include <Eigen/Core>


class MatrixCalculator
{
    Eigen::Matrix mat;
};
```

注意：

头文件：

```cpp
math.h
```

里面也暴露：

```cpp
#include <Eigen/Core>

class MatrixCalculator
{
    Eigen::Matrix m;
};
```

那么：

使用math的人：

必须知道Eigen。

关系：

```text
app

需要

math

需要

Eigen
```

所以：

```cmake
target_link_libraries(
    math

    PUBLIC

    Eigen
)
```

表示：

```text
math依赖Eigen

并且：

使用math的人也继承这个依赖
```

---

# 9.5 INTERFACE：只传递，不参与自身编译

这个比较特殊。

例如：

你创建一个纯头文件库。

目录：

```text
include

└── logger.hpp
```

没有：

```text
logger.cpp
```

代码：

```cpp
#include "logger.hpp"
```

所有代码都在头文件。

CMake：

```cmake
add_library(
    logger

    INTERFACE
)
```

表示：

创建一个接口库。

然后：

```cmake
target_include_directories(
    logger

    INTERFACE

    include
)
```

别人使用：

```cmake
target_link_libraries(
    app

    logger
)
```

于是：

app自动获得：

```text
include路径
```

但是：

logger自己不用编译。

---

# 9.6 三者对比

先记这个表：

| 关键字       | 自己使用 | 传递给依赖者 |
| --------- | ---- | ------ |
| PRIVATE   | ✅    | ❌      |
| PUBLIC    | ✅    | ✅      |
| INTERFACE | ❌    | ✅      |

---

举例：

## PRIVATE

```cmake
motor

PRIVATE

hardware
```

表示：

```text
motor内部使用hardware
```

别人不用知道。

---

## PUBLIC

```cmake
motor

PUBLIC

hardware
```

表示：

```text
motor使用hardware

而且用户motor也需要hardware
```

---

## INTERFACE

```cmake
config

INTERFACE

xxx
```

表示：

```text
config自己不用

但是使用它的人需要xxx
```

---

# 9.7 为什么现代CMake强调这个？

因为旧式写法：

```cmake
include_directories(
    /usr/include/opencv4
)
```

是全局的。

意思：

整个项目：

```text
所有target

都能看到OpenCV
```

问题：

大型项目：

```text
robot

camera

database

test
```

全部莫名其妙依赖OpenCV。

维护困难。

---

现代：

```cmake
target_include_directories(
    camera

    PRIVATE

    OpenCV/include
)
```

表示：

只有：

```text
camera
```

知道OpenCV。

---

# 9.8 回到你的STM32项目

假设：

你的STM32：

```text
stm32_app

motor

uart

pid
```

关系：

```text
stm32_app

 |
 +----motor
 |
 +----uart
 |
 +----pid
```

motor内部：

```text
motor

依赖

timer
```

那么：

```cmake
target_link_libraries(
    motor

    PRIVATE

    timer
)
```

因为：

timer只是motor内部实现。

---

但是：

如果：

```text
motor.h
```

里面：

```c
#include "encoder.h"


typedef struct
{
    Encoder encoder;

}Motor;
```

那么：

使用motor的人必须知道encoder。

应该：

```cmake
target_link_libraries(
    motor

    PUBLIC

    encoder
)
```

---

# 9.9 一个完整例子

目录：

```text
Robot

├── main.cpp
├── motor/
│   ├── motor.cpp
│   └── motor.h
│
└── hardware/
    ├── gpio.cpp
    └── gpio.h
```

关系：

```text
app

↓

motor

↓

hardware
```

CMake：

```cmake
add_library(
    hardware

    hardware/gpio.cpp
)


add_library(
    motor

    motor/motor.cpp
)


target_link_libraries(
    motor

    PRIVATE

    hardware
)


add_executable(
    app

    main.cpp
)


target_link_libraries(
    app

    motor
)
```

最终：

```text
app
 |
 |
 motor
 |
 |
 hardware
```

但是：

app不需要直接配置hardware。

---

# 9.10 本章核心记忆

以后看到：

```cmake
PRIVATE
```

脑子里翻译：

> 我自己用，别传出去。

---

```cmake
PUBLIC
```

翻译：

> 我用，而且别人用我也需要。

---

```cmake
INTERFACE
```

翻译：

> 我不用，但是别人用我需要。

---

到这里，你已经掌握现代 CMake 最核心的依赖模型：

```text
target

拥有：

源码
头文件路径
编译参数
库依赖

并且：

依赖可以传播
```

下一章：

# 第10章：CMake变量和常用内置变量

会解释你之前 STM32 里看到的：

```cmake
${PROJECT_NAME}
${CMAKE_CURRENT_SOURCE_DIR}
${CMAKE_CURRENT_BINARY_DIR}
```

以及：

```cmake
set()
message()
option()
```

这些是看懂复杂 CMakeLists 必须掌握的。
