---
title: 11_1_第11章_add_subdirectory()__多目录 CMake项目
description: 11_1_第11章_add_subdirectory()__多目录 CMake项目
categories:
  - 学习
tags:
  - CMake
  - ChatGPTGuides
date: 2026-09-13T11:10:56+08:00
lastmod: 2026-09-13T11:10:56+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
***第11章：`add_subdirectory()` —— 多目录 CMake 项目***

前面 1～10 章，我们一直在一个 `CMakeLists.txt` 里写：

```text
add_executable()
add_library()
target_sources()
target_include_directories()
target_link_libraries()
```

但是实际项目很少只有几个文件。

例如一个机器人项目可能是：

```text
RobotProject/
├── CMakeLists.txt
│
├── app/
│   ├── CMakeLists.txt
│   └── main.cpp
│
├── motor/
│   ├── CMakeLists.txt
│   ├── motor.cpp
│   └── motor.h
│
├── hardware/
│   ├── CMakeLists.txt
│   ├── hardware.cpp
│   └── hardware.h
│
└── tests/
    ├── CMakeLists.txt
    └── test_motor.cpp
```

这时候就需要：

```cmake
add_subdirectory()
```

---

# 11.1 `add_subdirectory()` 是干什么的？

最简单理解：

> **让 CMake 进入另一个目录，并处理这个目录里的 `CMakeLists.txt`。**

例如：

```cmake
add_subdirectory(motor)
```

假设：

```text
RobotProject/
├── CMakeLists.txt
└── motor/
    └── CMakeLists.txt
```

那么 CMake 处理顶层：

```text
RobotProject/CMakeLists.txt
```

遇到：

```cmake
add_subdirectory(motor)
```

就会继续处理：

```text
RobotProject/motor/CMakeLists.txt
```

---

# 11.2 最简单的例子

目录：

```text
RobotProject/
├── CMakeLists.txt
├── app/
│   └── main.cpp
└── motor/
    ├── CMakeLists.txt
    ├── motor.cpp
    └── motor.h
```

顶层：

```cmake
cmake_minimum_required(VERSION 3.20)

project(RobotProject)

add_subdirectory(motor)
add_subdirectory(app)
```

然后：

### `motor/CMakeLists.txt`

```cmake
add_library(motor)

target_sources(
    motor
    PRIVATE
        motor.cpp
)

target_include_directories(
    motor
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)
```

### `app/CMakeLists.txt`

```cmake
add_executable(robot)

target_sources(
    robot
    PRIVATE
        main.cpp
)

target_link_libraries(
    robot
    PRIVATE
        motor
)
```

---

# 11.3 CMake到底是怎么执行的？

这是这一章最重要的地方。

CMake 从顶层开始：

```text
RobotProject/CMakeLists.txt
```

执行：

```cmake
project(RobotProject)

add_subdirectory(motor)
add_subdirectory(app)
```

执行到：

```cmake
add_subdirectory(motor)
```

进入：

```text
motor/CMakeLists.txt
```

创建：

```text
motor
```

这个 target。

然后返回顶层。

接着：

```cmake
add_subdirectory(app)
```

进入：

```text
app/CMakeLists.txt
```

创建：

```text
robot
```

然后：

```cmake
target_link_libraries(robot PRIVATE motor)
```

于是形成：

```text
robot
  │
  │ 使用
  ▼
motor
```

最终整个项目形成：

```text
RobotProject
│
├── robot        ← executable target
│
└── motor        ← library target
```

---

# 11.4 这就是为什么 target 很重要

注意一个关键点。

`motor` 虽然是在：

```text
motor/CMakeLists.txt
```

里面创建的：

```cmake
add_library(motor)
```

但 `app` 目录里的：

```cmake
target_link_libraries(robot PRIVATE motor)
```

仍然可以使用它。

因为：

> **CMake 的 target 不等于某个 CMakeLists.txt 文件。**

target 是整个 CMake 构建系统中的一个对象。

所以：

```text
目录
   ↓
CMakeLists.txt
   ↓
创建 target
   ↓
其他目录可以建立 target 之间的依赖
```

这和你第 6 章学的 target 概念正好连接起来。

---

# 11.5 `add_subdirectory()` 和文件夹是什么关系？

这里要区分两个概念。

你之前问过：

> `robot` 是不是文件夹？

不是。

现在：

```cmake
add_subdirectory(motor)
```

这里的：

```text
motor
```

才确实是一个**目录路径**。

例如：

```text
RobotProject/
└── motor/
```

所以：

```cmake
add_subdirectory(motor)
```

可以理解成：

> 去 `motor/` 这个目录继续读取它的 CMake 配置。

而：

```cmake
add_library(motor)
```

这里的：

```text
motor
```

是：

> **target 名字**

两者只是恰好同名。

---

# 11.6 为什么真实项目喜欢这么组织？

假设你做一个机器人项目：

```text
RobotProject/
│
├── CMakeLists.txt
│
├── app/
│
├── motor/
│
├── sensor/
│
├── communication/
│
├── algorithm/
│
└── tests/
```

每个模块负责自己的构建：

```text
app
 ↓
robot executable

motor
 ↓
motor library

sensor
 ↓
sensor library

communication
 ↓
communication library

algorithm
 ↓
algorithm library
```

最终：

```text
                    robot
                   /     \
                  /       \
              motor      algorithm
                │           │
                ▼           ▼
             hardware     sensor
```

这比把所有东西都写进一个几百行甚至上千行的：

```text
CMakeLists.txt
```

更容易维护。

---

# 11.7 一个更接近实际项目的例子

目录：

```text
RobotProject/
│
├── CMakeLists.txt
│
├── app/
│   ├── CMakeLists.txt
│   └── main.cpp
│
├── motor/
│   ├── CMakeLists.txt
│   ├── motor.cpp
│   └── motor.h
│
└── hardware/
    ├── CMakeLists.txt
    ├── hardware.cpp
    └── hardware.h
```

顶层：

```cmake
cmake_minimum_required(VERSION 3.20)

project(RobotProject)

add_subdirectory(hardware)
add_subdirectory(motor)
add_subdirectory(app)
```

---

### hardware

`hardware/CMakeLists.txt`：

```cmake
add_library(hardware)

target_sources(
    hardware
    PRIVATE
        hardware.cpp
)

target_include_directories(
    hardware
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)
```

得到：

```text
hardware target
```

---

### motor

`motor/CMakeLists.txt`：

```cmake
add_library(motor)

target_sources(
    motor
    PRIVATE
        motor.cpp
)

target_include_directories(
    motor
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(
    motor
    PUBLIC
        hardware
)
```

得到：

```text
motor
  │
  │ PUBLIC
  ▼
hardware
```

---

### app

`app/CMakeLists.txt`：

```cmake
add_executable(robot)

target_sources(
    robot
    PRIVATE
        main.cpp
)

target_link_libraries(
    robot
    PRIVATE
        motor
)
```

得到：

```text
robot
  │
  │ PRIVATE
  ▼
motor
  │
  │ PUBLIC
  ▼
hardware
```

因此最终依赖关系：

```text
        robot
          │
          ▼
        motor
          │
          ▼
      hardware
```

而且因为：

```cmake
motor PUBLIC hardware
```

所以 `hardware` 的使用要求会向 `robot` 传播。

这正好把：

* 第6章 target
* 第7章 include
* 第8章 link
* 第9章 PUBLIC
* 第10章变量

全部串起来了。

---

# 11.8 `CMAKE_CURRENT_SOURCE_DIR` 在这里就变得非常重要

注意三个 `CMakeLists.txt`。

在：

```text
RobotProject/CMakeLists.txt
```

中：

```cmake
${CMAKE_CURRENT_SOURCE_DIR}
```

是：

```text
RobotProject/
```

进入：

```text
RobotProject/motor/CMakeLists.txt
```

之后：

```cmake
${CMAKE_CURRENT_SOURCE_DIR}
```

就变成：

```text
RobotProject/motor/
```

进入：

```text
RobotProject/hardware/CMakeLists.txt
```

之后：

```cmake
${CMAKE_CURRENT_SOURCE_DIR}
```

则是：

```text
RobotProject/hardware/
```

所以叫：

```text
CURRENT
```

是因为：

> **它表示当前正在处理的这个 CMakeLists.txt 所在的源码目录。**

这也是为什么我们可以放心写：

```cmake
target_include_directories(
    motor
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)
```

在 `motor/CMakeLists.txt` 中，它就是：

```text
motor/
```

---

# 11.9 `add_subdirectory()` 的一个重要规则

假设：

```text
RobotProject/
└── motor/
    └── CMakeLists.txt
```

顶层：

```cmake
add_subdirectory(motor)
```

那么 `motor/CMakeLists.txt` **不是独立运行的**。

它属于：

```text
整个 CMake 项目
```

也就是说：

```text
顶层 CMakeLists.txt
        │
        ├── add_subdirectory(motor)
        │       ↓
        │   motor/CMakeLists.txt
        │
        └── add_subdirectory(app)
                ↓
            app/CMakeLists.txt
```

所有这些最终共同组成一个 CMake 构建系统。

---

# 11.10 这和 Java Maven/Gradle 有点像

如果你有 Java 多模块项目：

```text
project
├── app
├── motor
└── hardware
```

你可以把它粗略类比为：

```text
Java:
模块
 ↓
模块依赖
```

CMake：

```text
目录
 ↓
CMakeLists.txt
 ↓
target
 ↓
target之间建立依赖
```

但要注意：

> **CMake 的核心不是“目录”，而是 target。**

目录只是帮助你组织 CMake 配置。

真正重要的是：

```text
robot
motor
hardware
```

这些 target 之间是什么关系。

---

# 11.11 现在你应该形成一个很重要的认识

不要把 CMake 理解成：

```text
CMake
 ↓
扫描所有文件夹
 ↓
自动编译
```

而应该理解成：

```text
顶层 CMakeLists.txt
        │
        ▼
add_subdirectory()
        │
        ▼
读取其他 CMakeLists.txt
        │
        ▼
创建各种 target
        │
        ▼
配置 target
        │
        ├── source
        ├── include
        ├── compile options
        └── libraries
        │
        ▼
建立 target 之间的依赖关系
        │
        ▼
生成构建系统
        │
        ▼
Make / Ninja
        │
        ▼
编译器
```

---

# 11.12 本章先记住这三个东西

### ① `add_subdirectory()`

```cmake
add_subdirectory(motor)
```

意思：

> 处理 `motor/` 目录中的 `CMakeLists.txt`。

---

### ② 目录 ≠ target

```cmake
add_subdirectory(motor)
```

`motor`：

> 目录。

而：

```cmake
add_library(motor)
```

`motor`：

> target。

只是名字可以相同。

---

### ③ 多目录项目最终仍然回到 target

```text
目录
 ↓
CMakeLists.txt
 ↓
target
 ↓
target之间的依赖
```

所以你前面学的 **target 思维**仍然是核心。

---

# 第11章到这里

目前你的 CMake 知识链已经变成：

```text
第1～5章
为什么需要 CMake
        ↓
CMake 如何运行
        ↓
第6章
target
        ↓
第7章
source / include
        ↓
第8章
library / link
        ↓
第9章
PRIVATE / PUBLIC / INTERFACE
        ↓
第10章
变量 / if / option
        ↓
第11章
add_subdirectory
        ↓
多目录项目
```

**下一章：第12章——`add_library()` 的深入使用：STATIC、SHARED、INTERFACE，以及 Header-only 库。**

这一章会把你前面已经接触过的：

```cmake
add_library()
```

真正讲透，并且会进一步解释为什么现代 CMake 中经常看到：

```cmake
add_library(xxx STATIC ...)
add_library(xxx SHARED ...)
add_library(xxx INTERFACE)
```

以及你以后在 OpenCV、ROS2、Qt 等大型 C++ 项目里会遇到的 `xxx::yyy` target。
