---
title: 10_1CMake变量和常用内置变量
description: 10_1CMake变量和常用内置变量
categories:
  - 学习
tags:
  - 单片机
  - STM32
  - 江科大
date: 2026-09-10T22:01:44+08:00
lastmod: 2026-09-10T22:01:44+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
你已经完成 **第 1～9 章**，现在已经掌握了 CMake 最核心的一条主线：

```text
CMake
 │
 ├── target
 │    ├── source
 │    ├── include
 │    └── library
 │
 └── target之间的依赖关系
      └── PRIVATE / PUBLIC / INTERFACE
```

接下来开始进入 **CMake 的“语言部分”**：变量、条件、函数、选项等。

---

***第10章：CMake变量 —— `set()` 和 `${}***`

这一章先解决一个非常基础、但以后会大量遇到的问题：

> **CMake里面的变量到底是什么？**

你之前已经见过很多这样的写法：

```cmake
${PROJECT_NAME}
```

例如：

```cmake
project(STM32Test)

add_executable(${PROJECT_NAME})
```

你现在应该已经知道：

```cmake
${PROJECT_NAME}
```

最终就是：

```cmake
STM32Test
```

但这里的 `${}` 到底是什么机制？

---

# 10.1 什么是变量？

先暂时不要把它想得太复杂。

变量就是：

> **给一个值起一个名字。**

例如：

```text
年龄 = 32
```

那么：

```text
年龄
```

就是变量名，

```text
32
```

就是变量的值。

CMake也是一样。

```cmake
set(NAME "robot")
```

意思就是：

```text
NAME = robot
```

然后：

```cmake
message(${NAME})
```

就可以使用这个值。

---

# 10.2 `set()`：给变量赋值

最基本的语法：

```cmake
set(变量名 变量值)
```

例如：

```cmake
set(NAME robot)
```

现在：

```text
NAME
 ↓
robot
```

再比如：

```cmake
set(VERSION 1.0)
```

就是：

```text
VERSION
   ↓
  1.0
```

---

# 10.3 `${}`：取变量的值

定义：

```cmake
set(NAME robot)
```

使用：

```cmake
${NAME}
```

于是：

```cmake
${NAME}
```

会被 CMake 替换成：

```text
robot
```

例如：

```cmake
set(NAME robot)

message(${NAME})
```

效果相当于：

```cmake
message(robot)
```

---

# 10.4 为什么前面经常看到 `${PROJECT_NAME}`？

因为：

```cmake
project(STM32Test)
```

执行以后，CMake 会提供一个变量：

```text
PROJECT_NAME
      ↓
 STM32Test
```

所以：

```cmake
add_executable(${PROJECT_NAME})
```

实际上相当于：

```cmake
add_executable(STM32Test)
```

这样写的好处是：

如果以后修改：

```cmake
project(STM32Test)
```

变成：

```cmake
project(MyRobot)
```

那么：

```cmake
add_executable(${PROJECT_NAME})
```

会自动变成：

```cmake
add_executable(MyRobot)
```

而不需要到处修改 `STM32Test`。

---

# 10.5 一个完整的小例子

```cmake
cmake_minimum_required(VERSION 3.20)

project(Robot)

set(SRC_DIR src)

add_executable(${PROJECT_NAME})

target_sources(
    ${PROJECT_NAME}
    PRIVATE
        ${SRC_DIR}/main.cpp
        ${SRC_DIR}/robot.cpp
)
```

这里出现了几个变量：

```text
PROJECT_NAME
      ↓
    Robot

SRC_DIR
      ↓
     src
```

所以 CMake 最终看到的效果大致就是：

```cmake
add_executable(Robot)

target_sources(
    Robot
    PRIVATE
        src/main.cpp
        src/robot.cpp
)
```

```bash
ly@dba13:~/ly_vscode/HelloMake/cmakeTest10_1$ cat src/main.cpp 
#include <iostream>
void say();
int main()
{
	say();
	return 0;
}
ly@dba13:~/ly_vscode/HelloMake/cmakeTest10_1$ cat src/robot.cpp 
#include <iostream>
void say()
{
	std::cout << "say in robot" << std::endl;
}
ly@dba13:~/ly_vscode/HelloMake/cmakeTest10_1$ rm -rf build
ly@dba13:~/ly_vscode/HelloMake/cmakeTest10_1$ mkdir build
ly@dba13:~/ly_vscode/HelloMake/cmakeTest10_1$ cd build
ly@dba13:~/ly_vscode/HelloMake/cmakeTest10_1/build$ cmake ..
-- The C compiler identification is GNU 14.2.0
-- The CXX compiler identification is GNU 14.2.0
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Check for working C compiler: /usr/bin/cc - skipped
-- Detecting C compile features
-- Detecting C compile features - done
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Check for working CXX compiler: /usr/bin/c++ - skipped
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Configuring done (0.8s)
-- Generating done (0.0s)
-- Build files have been written to: /home/ly/ly_vscode/HelloMake/cmakeTest10_1/build
ly@dba13:~/ly_vscode/HelloMake/cmakeTest10_1/build$ make
[ 33%] Building CXX object CMakeFiles/Robot.dir/src/main.cpp.o
[ 66%] Building CXX object CMakeFiles/Robot.dir/src/robot.cpp.o
[100%] Linking CXX executable Robot
[100%] Built target Robot
ly@dba13:~/ly_vscode/HelloMake/cmakeTest10_1/build$ ./Robot
say in robot

```

---

# 10.6 变量不一定只能存一个值

这一点很重要。

例如：

```cmake
set(SOURCES
    main.cpp
    robot.cpp
    motor.cpp
)
```

或者

```txt
set(SOURCES 
	${SRC_DIR}/main.cpp
	${SRC_DIR}/robot.cpp
)
```

可以理解成：

```text
SOURCES
   ↓
main.cpp
robot.cpp
motor.cpp
```

然后：

```cmake
add_executable(robot ${SOURCES})
```

就相当于：

```cmake
add_executable(
    robot
    main.cpp
    robot.cpp
    motor.cpp
)
```

所以你可以把变量理解成一个**名字对应的一组数据**。

---

# 10.7 为什么 CMake 经常使用变量？

假设你的项目：

```text
RobotProject/
├── CMakeLists.txt
├── src/
│   ├── main.cpp
│   ├── robot.cpp
│   └── motor.cpp
└── include/
    ├── robot.h
    └── motor.h
```

你可以写：

```cmake
set(SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)
set(INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)

add_executable(robot)

target_sources(
    robot
    PRIVATE
        ${SRC_DIR}/main.cpp
        ${SRC_DIR}/robot.cpp
        ${SRC_DIR}/motor.cpp
)

target_include_directories(
    robot
    PRIVATE
        ${INCLUDE_DIR}
)
```

这里：

```cmake
${CMAKE_CURRENT_SOURCE_DIR}
```

又是一个变量。

它表示：

> **当前正在处理的 CMakeLists.txt 所在的源代码目录。**

假设项目在：

```text
/home/ly/RobotProject
```

那么：

```cmake
${CMAKE_CURRENT_SOURCE_DIR}
```

就是：

```text
/home/ly/RobotProject
```

于是：

```cmake
${CMAKE_CURRENT_SOURCE_DIR}/src
```

就是：

```text
/home/ly/RobotProject/src
```

---

# 10.8 你现在需要认识的几个常用变量

先不用一次记几十个。

目前重点记这几个：

| 变量                         | 含义                         |
| -------------------------- | -------------------------- |
| `PROJECT_NAME`             | 当前项目名称                     |
| `CMAKE_CURRENT_SOURCE_DIR` | 当前 CMakeLists.txt 所在的源代码目录 |
| `CMAKE_CURRENT_BINARY_DIR` | 当前构建目录                     |
| `CMAKE_SOURCE_DIR`         | 顶层项目源代码目录                  |
| `CMAKE_BINARY_DIR`         | 顶层构建目录                     |


可以拆成两层来看：

## 1. 这两个是一组

```cmake
CMAKE_CURRENT_SOURCE_DIR
CMAKE_CURRENT_BINARY_DIR
```

它们的共同点是 **CURRENT**：

> **当前这个 CMakeLists.txt 对应的位置**

所以：

```text
CMAKE_CURRENT_SOURCE_DIR
        ↓
当前 CMakeLists.txt 所在的源码目录

CMAKE_CURRENT_BINARY_DIR
        ↓
当前 CMakeLists.txt 对应的构建目录
```

---

## 2. 另外两个是一组

```cmake
CMAKE_SOURCE_DIR
CMAKE_BINARY_DIR
```

它们**没有 `CURRENT`**，所以不是“当前 CMakeLists.txt”，而是针对**整个顶层项目**：

```text
CMAKE_SOURCE_DIR
        ↓
整个项目最顶层的源码目录

CMAKE_BINARY_DIR
        ↓
整个项目最顶层的构建目录
```

---

比如：

```text
RobotProject/                 ← 顶层
├── CMakeLists.txt
├── src/
└── motor/
    ├── CMakeLists.txt        ← 子项目
    └── ...
```

假设：

```text
RobotProject/build/
```

是构建目录。

那么在 `motor/CMakeLists.txt` 里面：

```cmake
CMAKE_CURRENT_SOURCE_DIR
```

是：

```text
RobotProject/motor
```

而：

```cmake
CMAKE_SOURCE_DIR
```

是：

```text
RobotProject
```

也就是说：

| 变量                         | 关键字        | 意思                            |
| -------------------------- | ---------- | ----------------------------- |
| `CMAKE_CURRENT_SOURCE_DIR` | CURRENT    | **当前** CMakeLists.txt 的源码目录   |
| `CMAKE_CURRENT_BINARY_DIR` | CURRENT    | **当前** CMakeLists.txt 对应的构建目录 |
| `CMAKE_SOURCE_DIR`         | 没有 CURRENT | **顶层**源码目录                    |
| `CMAKE_BINARY_DIR`         | 没有 CURRENT | **顶层**构建目录                    |

所以你刚才的理解可以进一步修正成一句非常好记的话：

> **`CURRENT` = 当前 CMakeLists.txt；不带 `CURRENT` = 整个顶层项目。**

而 `SOURCE / BINARY` 再决定它是在说：

> **源码这一边 / 构建这一边。**

所以其实是两个维度：

```text
                  SOURCE             BINARY
                  源码                构建
                   │                   │
CURRENT        当前源码目录       当前构建目录
                  │                   │
                  ↓                   ↓
           CMAKE_CURRENT_...   CMAKE_CURRENT_...

TOP           顶层源码目录       顶层构建目录
                  │                   │
                  ↓                   ↓
             CMAKE_SOURCE_DIR   CMAKE_BINARY_DIR
```

**这才是这一整组变量真正的结构。**

---

# 10.9 一个非常重要的区别

你之前的 STM32 CMake 项目中见过：

```cmake
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/stm32f103x8_flash.ld"
    "${CMAKE_CURRENT_BINARY_DIR}/stm32f103x8_flash.ld"
)
```

现在你应该能读懂一部分了。

假设：

```text
CMAKE_CURRENT_SOURCE_DIR
        ↓
/home/ly/STM32Project
```

那么：

```cmake
"${CMAKE_CURRENT_SOURCE_DIR}/stm32f103x8_flash.ld"
```

就是：

```text
/home/ly/STM32Project/stm32f103x8_flash.ld
```

而：

```text
CMAKE_CURRENT_BINARY_DIR
        ↓
/home/ly/STM32Project/build
```

所以：

```cmake
"${CMAKE_CURRENT_BINARY_DIR}/stm32f103x8_flash.ld"
```

就是：

```text
/home/ly/STM32Project/build/stm32f103x8_flash.ld
```

这也是为什么你之前看到：

```cmake
${CMAKE_CURRENT_SOURCE_DIR}
```

和：

```cmake
${CMAKE_CURRENT_BINARY_DIR}
```

会觉得有点抽象。

实际上就是：

```text
SOURCE_DIR
    ↓
源码在哪里？

BINARY_DIR
    ↓
构建文件放在哪里？
```

---

# 10.10 `message()`：查看变量到底是什么

学习 CMake 时这个非常有用。

例如：

```cmake
project(Robot)

message("PROJECT_NAME = ${PROJECT_NAME}")
message("SOURCE_DIR = ${CMAKE_CURRENT_SOURCE_DIR}")
message("BINARY_DIR = ${CMAKE_CURRENT_BINARY_DIR}")
```

运行 CMake 时，就可以看到类似：

```text
PROJECT_NAME = Robot
SOURCE_DIR = /home/ly/RobotProject
BINARY_DIR = /home/ly/RobotProject/build
```

所以以后看到一个你不理解的变量：

```cmake
${XXX}
```

可以先：

```cmake
message("XXX = ${XXX}")
```

看看它到底是什么。

## 例子

```txt


ly@dba13:~/ly_vscode/HelloMake/cmakeTest10_1/build$ cat ../CMakeLists.txt
cmake_minimum_required(VERSION 3.20)

message("hello world\n")

project(Robot)

message("PROJECT_NAME = ${PROJECT_NAME}")

set(SRC_DIR src)
set(SOURCES 
	${SRC_DIR}/main.cpp
	${SRC_DIR}/robot.cpp
)

add_executable(${PROJECT_NAME})

target_sources(
	${PROJECT_NAME}
	PRIVATE
	${SOURCES}
)

ly@dba13:~/ly_vscode/HelloMake/cmakeTest10_1/build$ cmake ..
hello world

-- The C compiler identification is GNU 14.2.0
-- The CXX compiler identification is GNU 14.2.0
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Check for working C compiler: /usr/bin/cc - skipped
-- Detecting C compile features
-- Detecting C compile features - done
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Check for working CXX compiler: /usr/bin/c++ - skipped
-- Detecting CXX compile features
-- Detecting CXX compile features - done
PROJECT_NAME = Robot
-- Configuring done (0.8s)
-- Generating done (0.0s)
-- Build files have been written to: /home/ly/ly_vscode/HelloMake/cmakeTest10_1/build
```

---

# 10.11 这里先不要急着记住所有变量

这一章真正要建立的是这个模型：

```text
set()
  │
  │ 给变量赋值
  ▼
NAME = robot
  │
  │ ${NAME}
  ▼
robot
```

也就是：

```cmake
set(NAME robot)

add_executable(${NAME})
```

≈

```cmake
add_executable(robot)
```

---

# 10.12 和你前面学的 target 联系起来

现在把第 6～10 章串起来：

```cmake
project(Robot)

set(SRC_DIR src)

add_executable(${PROJECT_NAME})

target_sources(
    ${PROJECT_NAME}
    PRIVATE
        ${SRC_DIR}/main.cpp
        ${SRC_DIR}/robot.cpp
)

target_include_directories(
    ${PROJECT_NAME}
    PRIVATE
        include
)
```

你现在应该能够逐行解释：

```cmake
project(Robot)
```

↓

创建项目，并得到：

```text
PROJECT_NAME = Robot
```

---

```cmake
set(SRC_DIR src)
```

↓

创建变量：

```text
SRC_DIR = src
```

---

```cmake
add_executable(${PROJECT_NAME})
```

↓

创建：

```text
Robot
```

这个 **executable target**。

---

```cmake
target_sources(...)
```

↓

告诉 `Robot`：

```text
你的源文件是：

src/main.cpp
src/robot.cpp
```

---

```cmake
target_include_directories(...)
```

↓

告诉 `Robot`：

```text
编译时去 include/ 里面寻找头文件。
```

---

到这里，**第10章的第一部分就完成了**。

下一部分我们会继续学：

> **CMake 的条件判断、`if()`、`option()`，以及为什么大型项目的 CMakeLists.txt 会出现大量 `if()`。**

这之后再进入 `add_subdirectory()`、多目录项目，届时你前面学的 **target + 依赖传播** 会真正串成一个完整项目结构。
