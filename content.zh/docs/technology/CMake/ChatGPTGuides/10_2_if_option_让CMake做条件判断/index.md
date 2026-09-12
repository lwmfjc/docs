---
title: 10_2_if_option_让CMake做条件判断
description: 10_2_if_option_让CMake做条件判断
categories:
  - 学习
tags:
  - CMake
  - ChatGPTGuides
date: 2026-09-12T22:18:35+08:00
lastmod: 2026-09-12T22:18:35+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
***第10章（续）：`if()`、`option()` —— 让 CMake 做条件判断***

上一节我们学习了：

```cmake
set()
${变量名}
message()
```

现在开始学习 CMake 的**逻辑控制**。

你以后看大型项目的 `CMakeLists.txt`，会经常看到：

```cmake
if(...)
    ...
else()
    ...
endif()
```

它的作用和 C/C++、Java 里的 `if` 非常接近：

```text
如果条件成立
    做 A
否则
    做 B
```

---

CMake 的 if() 中，明确的假值主要是：

```
FALSE
OFF
N
NO
0
""              空字符串
NOTFOUND
xxx-NOTFOUND
```

而：

```
ON
TRUE
YES
Y
1
```

是明确的真值。

***除此之外，其他普通字符串也会被当成 TRUE。***

CMake 的变量***本质上是字符串***，if() 在判断的时候，会**根据这个字符串的内容把它解释成真或者假**。 

# 10.13 最简单的 `if()`

例如：

```cmake
set(USE_ROBOT ON)

if(USE_ROBOT)
    message("使用机器人功能")
endif()
```

如果：

```text
USE_ROBOT = ON
```

那么：

```text
使用机器人功能
```

就会被输出。

---

## `else()`

```cmake
set(USE_ROBOT OFF)

if(USE_ROBOT)
    message("使用机器人功能")
else()
    message("不使用机器人功能")
endif()
```

执行逻辑：

```text
             USE_ROBOT
                 │
           ┌─────┴─────┐
           │           │
          ON          OFF
           │           │
           ▼           ▼
      使用机器人    不使用机器人
```

这里：

```cmake
endif()
```

就是：

> `if` 结束。

类似 C/C++：

```cpp
if (...)
{
}
```

---

# 10.14 `option()`：给用户一个开关

这个非常重要。

假设你写了一个机器人项目：

```text
RobotProject
├── CMakeLists.txt
├── src/
│   ├── main.cpp
│   └── robot.cpp
└── examples/
    └── demo.cpp
```

你希望用户可以选择：

```text
是否编译 demo？
```

可以：

```cmake
option(BUILD_DEMO "Build demo program" ON)
```

这句话可以理解为：

> 创建一个叫 `BUILD_DEMO` 的开关，默认打开。

然后：

```cmake
if(BUILD_DEMO)

    add_executable(demo
        examples/demo.cpp
    )

endif()
```

于是：

```text
BUILD_DEMO = ON
        ↓
编译 demo
```

如果：

```text
BUILD_DEMO = OFF
        ↓
不编译 demo
```

---

# 10.15 `option()` 和普通 `set()` 有什么区别？

这是一个很容易混淆的地方。

### `set()`

一般是：

> **给 CMake 内部使用的变量赋值。**

例如：

```cmake
set(SRC_DIR src)
```

表示：

```text
SRC_DIR = src
```

---

### `option()`

一般是：

> **提供一个可以由用户控制的 ON/OFF 开关。**

例如：

```cmake
option(BUILD_TESTS "Build tests" OFF)
```

表示：

```text
BUILD_TESTS
    ↓
  ON / OFF
```

所以：

```text
set()
    ↓
普通变量

option()
    ↓
配置选项 / 开关
```

---

# 10.16 为什么 `option()` 很有用？

看一个实际一点的项目。

假设你写机器人软件：

```text
RobotProject
│
├── robot
│
├── simulator
│
├── examples
│
└── tests
```

你可能希望：

```text
普通用户：
    只编译 robot

开发者：
    编译 robot + simulator + examples + tests
```

那么：

```cmake
option(BUILD_SIMULATOR "Build simulator" OFF)
option(BUILD_EXAMPLES "Build examples" OFF)
option(BUILD_TESTS "Build tests" OFF)
```

然后：

```cmake
if(BUILD_SIMULATOR)
    add_subdirectory(simulator)
endif()

if(BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

if(BUILD_TESTS)
    add_subdirectory(tests)
endif()
```

这样一个 CMake 项目就可以根据配置选择编译哪些东西。

---

# 10.17 `ON / OFF` 是什么？

你可以先简单理解：

```text
ON  = 开
OFF = 关
```

例如：

```cmake
set(DEBUG_MODE ON)
```

或者：

```cmake
set(DEBUG_MODE OFF)
```

然后：

```cmake
if(DEBUG_MODE)
    message("Debug模式")
endif()
```

---

# 10.18 `if()` 不只是判断 ON/OFF

还可以比较数字。

例如：

```cmake
set(VERSION_NUMBER 3)

if(VERSION_NUMBER GREATER 2)
    message("版本大于2")
endif()
```

这里：

```text
GREATER
```

就是：

> 大于

常见的几个：

```text
GREATER         >
LESS            <
EQUAL           =
GREATER_EQUAL   >=
LESS_EQUAL      <=
```

例如：

```cmake
if(VERSION_NUMBER GREATER_EQUAL 3)
    message("支持新版本")
endif()
```

相当于：

```cpp
if (VERSION_NUMBER >= 3)
```

---

# 10.19 字符串比较

例如：

```cmake
set(COMPILER "gcc")

if(COMPILER STREQUAL "gcc")
    message("使用 GCC")
endif()
```

这里：

```text
STREQUAL
```

就是：

> 字符串相等。

所以：

```cmake
if(COMPILER STREQUAL "gcc")
```

可以理解成：

```cpp
if (COMPILER == "gcc")
```

---

# 10.20 `AND / OR / NOT`

CMake 也支持逻辑运算。

例如：

```cmake
if(BUILD_TESTS AND BUILD_EXAMPLES)
    message("测试和示例都开启了")
endif()
```

对应：

```text
AND = 并且
```

---

```cmake
if(BUILD_TESTS OR BUILD_EXAMPLES)
    message("至少开启了一个")
endif()
```

对应：

```text
OR = 或者
```

---

```cmake
if(NOT BUILD_TESTS)
    message("没有开启测试")
endif()
```

对应：

```text
NOT = 不
```

所以和你熟悉的 C/C++ 很接近：

```cpp
if (A && B)
```

↓

```cmake
if(A AND B)
```

---

# 10.21 一个完整的小项目

现在把前面的知识串起来。

目录：

```text
RobotProject/
├── CMakeLists.txt
├── src/
│   ├── main.cpp
│   └── robot.cpp
└── examples/
    └── demo.cpp
```

`CMakeLists.txt`：

```cmake
cmake_minimum_required(VERSION 3.20)

project(RobotProject)

# 是否编译示例
option(BUILD_EXAMPLES "Build example programs" OFF)


# 主程序
add_executable(${PROJECT_NAME})

target_sources(
    ${PROJECT_NAME}
    PRIVATE
        src/main.cpp
        src/robot.cpp
)


# 示例程序
if(BUILD_EXAMPLES)

    add_executable(robot_demo)

    target_sources(
        robot_demo
        PRIVATE
            examples/demo.cpp
    )

endif()
```

默认：

```text
BUILD_EXAMPLES = OFF
```

所以：

```text
构建：

RobotProject
```

不会构建：

```text
robot_demo
```

如果用户配置：

```bash
cmake -S . -B build -DBUILD_EXAMPLES=ON
```

那么：

```text
BUILD_EXAMPLES = ON
```

于是：

```text
RobotProject
robot_demo
```

两个 target 都会被生成。

---

# 10.22 这里出现了一个非常重要的东西：`-D`

你之前运行 CMake 可能见过：

```bash
cmake -S . -B build
```

现在：

```bash
cmake -S . -B build -DBUILD_EXAMPLES=ON
```

这里：

```text
-D
```

可以先理解成：

> **在运行 CMake 时给变量设置值。**

也就是：

```bash
-DBUILD_EXAMPLES=ON
```

相当于告诉 CMake：

```text
BUILD_EXAMPLES = ON
```

因此：

```cmake
option(BUILD_EXAMPLES "..." OFF)
```

虽然默认是：

```text
OFF
```

但是命令行可以覆盖：

```bash
-DBUILD_EXAMPLES=ON
```

这就是 CMake 项目非常常见的配置方式。

---

# 10.23 你现在可以理解 CMake 的一个完整流程了

例如：

```bash
cmake -S . -B build -DBUILD_EXAMPLES=ON
```

大致发生：

```text
                CMakeLists.txt
                       │
                       ▼
                project(Robot)
                       │
                       ▼
               option(BUILD_EXAMPLES)
                       │
                       ▼
             BUILD_EXAMPLES = ON
                       │
                       ▼
                   if(...)
                       │
                       ▼
              创建 robot_demo target
                       │
                       ▼
                 CMake 生成
                       │
                       ▼
                Makefile / Ninja
                       │
                       ▼
                    编译
```

所以你现在已经开始从：

> “CMake 是一个配置文件”

进入：

> **“CMake 是一门用来描述和配置构建过程的语言。”**

---

# 10.24 一个很重要的认识

到这里，你可以把 CMake 的东西分成三类：

### 第一类：创建 target

```cmake
add_executable()
add_library()
```

---

### 第二类：描述 target

```cmake
target_sources()
target_include_directories()
target_link_libraries()
target_compile_definitions()
target_compile_options()
```

---

### 第三类：控制 CMake 的行为

```cmake
set()
option()
if()
else()
endif()
message()
```

形成：

```text
                    CMake
                      │
        ┌─────────────┼─────────────┐
        │             │             │
     创建Target     配置Target     控制逻辑
        │             │             │
   add_executable   target_*      set
   add_library                     option
                                   if
                                   message
```

这张关系图很重要。

你前面第 6～9 章主要是在学：

```text
Target
```

现在第 10 章开始学习：

```text
CMake语言本身
```

---

# 10.25 到这里，第10章暂时告一段落

目前第10章你应该掌握：

```text
set()
    ↓
创建/修改变量

${VAR}
    ↓
读取变量

message()
    ↓
打印变量/调试

if()
    ↓
条件判断

else()
    ↓
否则

endif()
    ↓
结束条件判断

option()
    ↓
创建 ON/OFF 配置开关

-DXXX=YYY
    ↓
从命令行给 CMake 变量传值
```

下一章我们进入一个对**大型 CMake 项目非常重要**的内容：

# 第11章：`add_subdirectory()` —— 多目录项目

这会开始解释为什么真实项目不是一个巨大的：

```text
CMakeLists.txt
```

而是：

```text
RobotProject/
├── CMakeLists.txt
├── src/
│   ├── CMakeLists.txt
│   └── ...
├── motor/
│   ├── CMakeLists.txt
│   └── ...
├── hardware/
│   ├── CMakeLists.txt
│   └── ...
└── tests/
    ├── CMakeLists.txt
    └── ...
```

并且这一章会把你之前学的：

**target → target依赖 → PRIVATE/PUBLIC → 变量**

真正组合起来。
