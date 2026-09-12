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
#xxx 自己编译时需要去 include 找头文件，同时使用 xxx 的 target 也需要这个 include 路径。
```

> 1. CMake 中，target 的 usage requirements（使用要求）会沿着依赖关系向下游传播。
> 2. 这里就提前说明了，target 的头文件**搜索路径**、**链接库**等使用要求，可以传递给依赖它的 target。

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
#include "math.h"

void MatrixCalculator::calculate()
{
    // 真正的实现
}
```

注意：

头文件：

```cpp
math.h
```

里面也暴露：

```cpp
#pragma once

#include <Eigen/Core>

class MatrixCalculator
{
public:
    Eigen::MatrixXd calculate();
};
```

那么：

使用math的人：

要`include "math.h" `就必须知道Eigen ~~因为.h中的声明类型有Eigen::MatrixXd ~~ 。

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


# 9.5 INTERFACE：只传递，不参与自身编译

这个比较特殊。

例如：

你创建一个纯头文件库。 ~~纯头文件库 ≠ “只有声明的头文件库”，而是库的实现也放在头文件中，因此使用者不需要单独链接一个编译好的库二进制文件。~~ 

> 1. 纯头文件库的实现会随着 `#include` 进入每个 .cpp 的编译单元，因此可能增加编译时间；但只要库按照 C++ 的规则设计（例如 inline、模板等），多个 .cpp 同时包含它通常不会产生重复定义的链接冲突。
> 2. 对于 inline，编译器/链接器有机制允许多个定义存在，并且通常会选择/合并其中一个版本。如果你违反 ODR，程序可能直接编译链接成功 ~~也可能失败~~ ，但行为是未定义的（Undefined Behavior）。这点非常重要。

## 1. `logger`

目录：

```text
logger/
├── CMakeLists.txt
└── include/
    └── logger.hpp
```

`logger.hpp`：

```cpp
#pragma once

void log(const char* msg)
{
    // 实现
}
```

CMake：

```cmake
add_library(logger INTERFACE)

target_include_directories(
    logger
    INTERFACE
    include
)
```

这里的：

```cmake
add_library(logger INTERFACE)
```

实际上是在告诉 CMake：

> **logger 是一个“接口 target”，它本身没有需要编译的源文件。**

所以 CMake 不会做：

```text
logger.cpp
   ↓
logger.o
```

因为根本没有 `logger.cpp`。

## 2. 那 `target_include_directories(... INTERFACE include)` 是什么意思？

它不是说：

> “logger 自己去 `include` 找头文件。”

而是：

> **凡是使用 `logger` 的 target，都需要把 `include` 加入自己的头文件搜索路径。**

例如：

```cmake
target_link_libraries(
    app
    PRIVATE
    logger
)
```

CMake 就知道：

```text
app
 ↓
使用 logger
 ↓
继承 logger 的 INTERFACE include 路径
 ↓
app 编译时增加：
logger/include/
```

于是 `app.cpp`：

```cpp
#include <logger.hpp>

int main()
{
    log("hello");
}
```

编译时就能找到：

```text
logger/include/logger.hpp
```

## 3. 如果logger依赖了`math` 

假设：

```text
logger/
└── include/
    └── logger.hpp

math/
└── include/
    └── math.hpp
```

然后：

```cpp
// logger.hpp

#include <math.hpp>

inline void log()
{
    math::something();
}
```

此时 `logger` 依赖 `math`。

如果：

```cmake
add_library(logger INTERFACE)

target_include_directories(
    logger
    INTERFACE
    include
)

target_link_libraries(
    logger
    INTERFACE
    math
)
```

这里就非常有意思了。

因为：

```text
logger
  │
  │ INTERFACE
  ↓
 math
```

意思是：

> **logger 自己不需要编译，但凡是使用 logger 的人，也需要 math。**

于是：

```cmake
target_link_libraries(
    app
    PRIVATE
    logger
)
```

形成：

```text
app
 │
 ↓
logger
 │
 ↓
math
```

最终 `app` 编译的时候：

```text
app.cpp
  │
  ├── #include <logger.hpp>
  │
  ↓
logger.hpp
  │
  ├── #include <math.hpp>
  │
  ↓
math.hpp
```

***所以 app 必须能够找到 `math.hpp`。***

而 CMake 会通过：

```cmake
target_link_libraries(logger INTERFACE math)
```

**把 `math` 的使用要求继续传给 `app`**。


## 4. 概述

> logger 自己是不需要编译的，所以压根不需要知道头文件 math 去哪里找。


因为：

```text
logger
```

没有：

```text
logger.cpp
```

所以 CMake 不需要建立：

```text
logger.cpp → logger.o
```

这个编译过程。

因此：

```cmake
target_include_directories(
    logger
    INTERFACE
    ...
)
```

中的 `INTERFACE` 就表示：

> **这个 include 路径不是给 logger 自己编译用的，而是给 logger 的使用者用的。**


```text
                 logger
                   │
             提供 usage requirements
                   │
        ┌──────────┴──────────┐
        ↓                     ↓
    include路径             math依赖
        │                     │
        └──────────┬──────────┘
                   ↓
                  app
                   ↓
                 编译
```

而真正的 C++ `#include`：

```cpp
#include <logger.hpp>
```

把头文件内容**文本意义上纳入当前翻译单元**。

也就是说：

```text
CMake
 ↓
负责告诉编译器：
“去 logger/include 找头文件”

        ↓

编译器预处理
 ↓

#include <logger.hpp>
 ↓
把 logger.hpp 的内容纳入 app.cpp
```

所以最好把两件事情分开：

### CMake 的工作

```text
target_link_libraries(app PRIVATE logger)
                     ↓
继承 logger 的 usage requirements
                     ↓
获得 include 路径、依赖等
```

### C++ 预处理器的工作

```text
app.cpp
 ↓
#include <logger.hpp>
 ↓
logger.hpp 的内容进入这个翻译单元
```

## 5. 最后用一句话总结 


> `logger` 是 INTERFACE target，因此它自己没有需要编译的源文件，所以 `logger` 自己不存在“编译 logger.hpp 时去哪里找 math.hpp”这个编译过程。`logger` 的作用主要是向它的使用者传播使用要求。当 `app` 使用 `logger` 后，`logger` 的 INTERFACE include 路径以及它的 INTERFACE 依赖会传递给 `app`；然后真正编译 `app.cpp` 时，`app` 才会通过这些路径找到 `logger.hpp`、`math.hpp` 等头文件。


这就是 `INTERFACE` target 最核心的思想。

还有一个特别重要的点：**`target_link_libraries(app logger)` 并不是把 `logger.hpp` “复制进 app”**。它是在建立 **CMake target 之间的依赖关系**；真正让头文件内容进入 `app.cpp` 的，是 `#include`。

# 9.6 三者对比

先记这个表：

| 关键字       | 自己使用 | 传递给依赖者 |
| --------- | ---- | ------ |
| PRIVATE   | ✅    | ❌      |
| PUBLIC    | ✅    | ✅      |
| INTERFACE | ❌    | ✅      |

PUBLIC / PRIVATE / INTERFACE 是 CMake 用来描述 target 属性 **“自己使用”** 和 **“向下游传播”** 关系的关键字，CMake 会**把某个*target*的使用要求传递给*依赖者***，这就是 CMake 所说的 ***usage requirements（使用要求）传播***。

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

## PUBLIC

```cmake
motor

PUBLIC

hardware
```

表示：

```text
motor使用hardware

而且依赖motor的target也需要hardware
```


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
