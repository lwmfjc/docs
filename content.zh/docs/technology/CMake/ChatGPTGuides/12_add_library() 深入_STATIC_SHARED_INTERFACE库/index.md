---
title: 12_add_library() 深入_STATIC_SHARED_INTERFACE库
description: 12_add_library() 深入_STATIC_SHARED_INTERFACE库
categories:
  - 学习
tags:
  - CMake
  - ChatGPTGuides
date: 2026-09-14T19:44:27+08:00
lastmod: 2026-09-14T19:44:27+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
***第12章：`add_library()` 深入 —— STATIC / SHARED / INTERFACE 库***

这一章非常重要，因为你前面已经学会：

```cmake
add_executable()
add_library()
```

但是之前我们只是简单理解：

```cmake
add_library(motor)
```

创建一个库 target。

实际项目中，你会经常看到：

```cmake
add_library(
    xxx
    STATIC
    ...
)
```

或者：

```cmake
add_library(
    xxx
    SHARED
    ...
)
```

甚至：

```cmake
add_library(
    xxx
    INTERFACE
)
```

这一章就是把它们讲清楚。

---

# 12.1 回顾：什么是 library？

先回忆 C/C++ 编译流程：

```text
.cpp
 |
 | 编译
 ↓
.o 文件
 |
 | 链接
 ↓
可执行文件
```

例如：

```text
main.cpp
robot.cpp
motor.cpp
```

编译：

```bash
g++ -c main.cpp
g++ -c motor.cpp
g++ -c robot.cpp
#main.o
#robot.o
#motor.o
```

链接：

```bash
g++ main.o motor.o robot.o -o robot_app
robot_app
```

---

但是如果项目很大：

```text
robot/
├── motor
│   ├── motor.cpp
│   ├── motor.h
│
├── sensor
│   ├── sensor.cpp
│   └── sensor.h
│
└── main.cpp
```

我们可能希望：

先把：

```text
motor
```

单独编译成一个库：

```text
libmotor.a
```

然后：

```text
main
```

链接它。

结构：

```text
main.cpp
   |
   |
   ↓
libmotor
   |
   |
motor.cpp
```

这就是 library。

## .c与库编译程序


# 12.2 `add_library()` 基本形式

语法：

```cmake
add_library(
    target_name
    类型
    源文件
)
```

例如：

```cmake
add_library(
    motor
    STATIC
    motor.cpp
)
```

意思：

创建一个：

```text
motor库
```

类型：

```text
STATIC
```

源文件：

```text
motor.cpp
```

---

# 12.3 STATIC 库（静态库）

最常见：

```cmake
add_library(
    motor
    STATIC
    motor.cpp
)
```

生成：

Linux：

```text
libmotor.a
```

Windows：

```text
motor.lib
```

---

## 什么叫静态？

简单理解：

> 编译时，把库代码复制进最终程序。

例如：

```text
libmotor.a
```

里面：

```text
motor.o
```

然后：

```text
main
   +
libmotor.a
   |
   ↓
robot.exe
```

最终：

```text
robot.exe
```

自己包含 motor 的代码。

---

类似：

Java：

```text
jar包打进最终程序
```

---

# 12.4 SHARED 库（动态库）

写：

```cmake
add_library(
    motor
    SHARED
    motor.cpp
)
```

生成：

Linux：

```text
libmotor.so
```

Windows：

```text
motor.dll
```

---

动态库特点：

程序运行时加载。

结构：

```text
robot.exe

运行时

 ↓

libmotor.so
```

程序里面：

保存：

> 我要调用 motor 库

但是代码：

存在：

```text
libmotor.so
```

---

例如 Linux：

```bash
ldd robot
```

可以看到：

```text
libmotor.so
```

---

# 12.5 STATIC 和 SHARED 区别

简单比较：

|      | STATIC | SHARED  |
| ---- | ------ | ------- |
| 文件   | `.a`   | `.so`   |
| 链接时间 | 编译时    | 运行时     |
| 程序大小 | 较大     | 较小      |
| 部署   | 简单     | 需要带动态库  |
| 修改库  | 需要重新链接 | 替换.so即可 |

---

实际开发：

嵌入式：

经常：

```text
STATIC
```

因为：

* 单文件方便烧录
* 不需要运行环境找库

Linux服务器：

经常：

```text
SHARED
```

因为：

* 多程序共享库
* 节省空间

---

# 12.6 现代 CMake 推荐写法

以前：

```cmake
add_library(
    motor
    STATIC
    motor.cpp
)
```

也可以。

但是现代 CMake 更喜欢：

```cmake
add_library(
    motor
)
```

然后：

```cmake
target_sources(
    motor
    PRIVATE
        motor.cpp
)
```

为什么？

因为：

target 创建：

```text
motor
```

之后：

所有属性都通过：

```text
target_xxx()
```

设置。

和你前面学习保持一致。

---

例如：

```cmake
add_library(
    motor
    STATIC
)


target_sources(
    motor
    PRIVATE
        motor.cpp
)


target_include_directories(
    motor
    PUBLIC
        include
)
```

更符合现代 CMake 风格。

---

# 12.7 INTERFACE 库

这个非常重要。

先回忆第9章：

```cmake
INTERFACE
```

表示：

> 自己不需要，但是传递给别人。

现在：

```cmake
add_library(
    config
    INTERFACE
)
```

是什么意思？

创建一个：

**没有源代码的库 target。**

---

例如：

项目：

```text
Robot/
├── include/
│   └── config.h
```

里面：

```cpp
#define MOTOR_SPEED 100
```

没有：

```text
config.cpp
```

只有头文件。

传统：

```cmake
include_directories(include)
```

但是现代：

创建接口库：

```cmake
add_library(
    config
    INTERFACE
)
```

然后：

```cmake
target_include_directories(
    config
    INTERFACE
        include
)
```

---

使用：

```cmake
target_link_libraries(
    robot
    PRIVATE
        config
)
```

效果：

robot 自动获得：

```text
include路径
```

但是：

不会产生：

```text
libconfig.a
```

因为它没有代码。

---

# 12.8 INTERFACE库有什么意义？

可能你会问：

> 没有代码，为什么叫 library？

因为 CMake 中：

library 不一定代表文件。

更准确：

> target 是一个构建对象，可以保存使用规则。

---

例如：

```cmake
config
```

保存：

```text
include目录
编译宏
编译选项
依赖
```

它本身：

不生成任何东西。

---

这和第9章完全对应：

```text
INTERFACE

自己：
❌ 编译

别人：
✅ 获得配置
```

---

# 12.9 一个实际机器人项目例子

目录：

```text
Robot/
├── CMakeLists.txt
│
├── motor/
│   ├── motor.cpp
│   └── motor.h
│
├── sensor/
│   ├── sensor.cpp
│   └── sensor.h
│
└── main.cpp
```

顶层：

```cmake
add_library(
    motor
    STATIC
)


target_sources(
    motor
    PRIVATE
        motor/motor.cpp
)


target_include_directories(
    motor
    PUBLIC
        motor
)


add_library(
    sensor
    STATIC
)


target_sources(
    sensor
    PRIVATE
        sensor/sensor.cpp
)


target_include_directories(
    sensor
    PUBLIC
        sensor
)


add_executable(
    robot
)


target_sources(
    robot
    PRIVATE
        main.cpp
)


target_link_libraries(
    robot
    PRIVATE
        motor
        sensor
)
```

最终：

```text
              robot

          /          \

       motor        sensor

        |             |

    motor.cpp     sensor.cpp
```

---

# 12.10 ROS2 为什么大量使用 INTERFACE？

你以后学 ROS2 会看到：

```cmake
ament_target_dependencies()
```

底层思想类似。

例如：

一个消息包：

```text
robot_msgs
```

里面：

```text
.msg文件
```

没有：

```cpp
源代码
```

它主要提供：

* 类型定义
* include路径
* 依赖信息

这种东西天然接近：

```cmake
INTERFACE target
```

---

# 12.11 本章总结

现在你应该知道：

## `STATIC`

```cmake
add_library(
    motor
    STATIC
)
```

表示：

> 编译成静态库 `.a`

---

## `SHARED`

```cmake
add_library(
    motor
    SHARED
)
```

表示：

> 编译成动态库 `.so/.dll`

---

## `INTERFACE`

```cmake
add_library(
    config
    INTERFACE
)
```

表示：

> 创建一个只传递使用要求的 target，没有实际代码。

---

核心思想：

以前：

```text
library = 一个文件
```

现在：

现代 CMake：

```text
library ≈ 一个 target

可能：
    有代码
    有库文件

也可能：
    只有配置规则
```

---

下一章：

# 第13章：`find_package()` —— 使用第三方库（OpenCV、Qt、ROS2）

这一章会回答你之前问过的问题：

> `target_link_libraries(robot OpenCV)`
> CMake到底在哪里找到 OpenCV？

以及：

```cmake
find_package(OpenCV REQUIRED)
```

到底做了什么。

这也是进入 ROS2 / OpenCV / Qt 开发前必须掌握的一章。
