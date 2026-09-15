---
title: 14_编译选项与宏定义_ target_compile_options、target_compile_definitions
description: 14_编译选项与宏定义_ target_compile_options、target_compile_definitions
categories:
  - 学习
tags:
  - CMake
  - ChatGPTGuides
date: 2026-09-15T17:42:54+08:00
lastmod: 2026-09-15T17:42:54+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
***第14章：编译选项与宏定义 —— `target_compile_options()`、`target_compile_definitions()`***  


前面我们学习的内容主要解决：

* 有哪些源文件？
* 头文件在哪里？
* 依赖哪些库？
* target之间怎么连接？

但是实际 C++ 项目还有一类非常重要的问题：

> **编译器应该用什么参数编译？**

例如：

* 开启所有警告
* 开启优化
* 生成调试信息
* 定义 DEBUG 宏
* 根据平台选择不同代码

这些都属于：

**编译选项（compile options）**

---

# 14.1 先回忆编译命令

假设：

```cpp
// main.cpp
#include <iostream>

int main()
{
    return 0;
}
```

普通编译：

```bash
g++ main.cpp
```

实际上：

编译器有很多隐藏参数。

例如：

```bash
g++ \
-Wall \
-O2 \
-g \
-std=c++17 \
main.cpp
```

这里：

```text
-Wall
```

开启警告。

```text
-O2
```

优化。

```text
-g
```

生成调试信息。

```text
-std=c++17
```

使用 C++17。

```bash
╭─ ~/ly_vscode/HelloCMake/14_1 main ?1                      
╰─❯ g++ -dM -E -x c++ /dev/null | grep __cplusplus #查找默认标准
#define __cplusplus 201703L
```

> g++默认可以编译很多标准。-std=c++17 就是指定「按照 C++17 语言规范编译这个程序」，让编译器知道可以使用 C++17 提供的语法和库。
---

以前可能这样写：

```cmake
set(CMAKE_CXX_FLAGS "-Wall -O2")
```

但是现代 CMake 不推荐。

为什么？

因为它是：

**全局设置。**

---

# 14.2 为什么不推荐全局编译选项？

例如：

项目：

```
Robot/

├── robot
│
├── third_party
│   └── xxx
```

你写：

```cmake
set(
    CMAKE_CXX_FLAGS
    "-Wall"
)
```

结果：

所有 target：

```text
robot

third_party_xxx

test
```

都会获得：

```
-Wall
```

---

但是：

第三方库可能：

* 有大量警告
* 不希望修改编译方式
* 需要特殊参数

所以现代 CMake：

强调：

> 编译选项属于 target。

---

# 14.3 `target_compile_options()`

语法：

```cmake
target_compile_options(
    target
    PRIVATE/PUBLIC/INTERFACE
    编译参数
)
```

例如：

```cmake
add_executable(
    robot
    main.cpp
)


target_compile_options(
    robot
    PRIVATE
    -Wall
)
```

效果：

编译：

```bash
#相当于
g++ -Wall main.cpp
```

---

# 14.4 PRIVATE / PUBLIC / INTERFACE 在这里是什么意思？

和第9章完全一样。

## PRIVATE

只影响自己。

例如：

```cmake
target_compile_options(
    motor
    PRIVATE
    -Wall
)
```

关系：

```
motor
 |
 |-Wall
```

使用 motor 的：

```
robot
```

不会继承。

---

## PUBLIC

自己使用，并传播。

例如：

```cmake
target_compile_options(
    motor
    PUBLIC
    -Wall
)
```

关系：

```
robot

 ↓

motor

 ↓

-Wall
```

---

## INTERFACE

自己不用，只给别人。

例如：

```cmake
target_compile_options(
    config
    INTERFACE
    -Wall
)
```

意思：

```
INTERFACE 属性只传播给依赖者，本 target 不消费该属性。即使 target 本身是 STATIC/SHARED 库，也一样。
依赖config的人获得-Wall
```

---

# 14.5 常见编译选项

## 1. 警告

### GCC / Clang：

```cmake
-Wall
```

开启常见警告。

例如：

```cpp
int a;

```

可能提示：

```
unused variable
```

```shell
╭─ ~/ly_vscode/HelloCMake/14_1/build main ?1                                            7s ≡
╰─❯ cmake ..
-- Configuring done (0.0s)
-- Generating done (0.0s)
-- Build files have been written to: /home/ly/ly_vscode/HelloCMake/14_1/build

╭─ ~/ly_vscode/HelloCMake/14_1/build main ?1                                               ≡
╰─❯ make
[ 50%] Building CXX object CMakeFiles/robot.dir/main.cpp.o
/home/ly/ly_vscode/HelloCMake/14_1/main.cpp: In function ‘int main()’:
/home/ly/ly_vscode/HelloCMake/14_1/main.cpp:6:13: warning: unused variable ‘a’ [-Wunused-variable]
    6 |         int a;
      |             ^
[100%] Linking CXX executable robot
[100%] Built target robot
```

---

更严格：

```cmake
-Wextra #再额外开启另一批更严格警告
```

更多警告。

---

甚至：

```cmake
-Werror
```

把警告当错误。

例如：

警告：

```
unused variable
```

变成：

```
error
```

---

实际项目：

经常：

```cmake
target_compile_options(
    robot
    PRIVATE
    -Wall
    -Wextra
)
```

---

# 14.6 优化等级

编译器优化：

## Debug：

```bash
-g -O0
```

特点：

* 不优化
* 容易调试
* 程序慢

---

## Release：

```bash
-O3
```

特点：

* 高优化
* 程序快
* 不方便调试

---

CMake：

一般不用自己写：

```cmake
-O3
```

而是：

```bash
cmake -DCMAKE_BUILD_TYPE=Release ..
```

或者：

```bash
cmake -DCMAKE_BUILD_TYPE=Debug ..
```

后面第15章详细讲。

---

# 14.7 C++标准设置

例如：

需要 C++17：

以前：

```cmake
set(
    CMAKE_CXX_STANDARD
    17
)
```

全局。

现代：

```cmake
target_compile_features(
    robot
    PRIVATE
    cxx_std_17
)
```

或者：

```cmake
set_target_properties(
    robot
    PROPERTIES
    CXX_STANDARD 17
)
```

---

推荐：

```cmake
target_compile_features(
    robot
    PRIVATE
    cxx_std_17
)
```

---

# 14.8 `target_compile_definitions()` —— 定义宏

这个非常重要。

对应 C/C++：

```cpp
#define XXX
```

例如：

代码：

```cpp
#ifdef DEBUG_MODE

#include <iostream>

#endif
```

如果定义：

```cpp
#define DEBUG_MODE
```

代码存在。

没有：

代码消失。

---

以前：

```bash
g++ -DDEBUG_MODE main.cpp
```

现在：

CMake：

```cmake
target_compile_definitions(
    robot
    PRIVATE
    DEBUG_MODE
)
```

等价：

```bash
g++ -DDEBUG_MODE
```

---

# 14.9 示例：Debug模式切换

代码：

```cpp
#include <iostream>


int main()
{

#ifdef DEBUG_MODE

    std::cout
        << "debug mode\n";

#endif


    return 0;
}
```

CMake：

```cmake
option(
    ENABLE_DEBUG
    "enable debug"
    OFF
)


add_executable(
    robot
    main.cpp
)


if(ENABLE_DEBUG)

    target_compile_definitions(
        robot
        PRIVATE
        DEBUG_MODE
    )

endif()
```

运行：

默认：

```bash
cmake ..
```

没有输出。

开启：

```bash
cmake .. -DENABLE_DEBUG=ON
```

输出：

```
debug mode
```

---

# 14.10 为什么不用直接写`#define`？

例如：

```cpp
#define DEBUG_MODE
```

当然可以。

但是：

问题：

每次修改代码。

---

CMake方式：

```bash
cmake .. -DENABLE_DEBUG=ON
```

同一个代码：

可以生成：

Debug版本：

```
DEBUG_MODE存在
```

Release版本：

```
不存在
```

---

这就是工程实践。

---

# 14.11 实际机器人项目例子

比如：

传感器驱动：

```cpp
#ifdef SIMULATION

// Gazebo模拟

#else

// 真硬件

#endif
```

CMake：

仿真：

```cmake
target_compile_definitions(
    robot
    PRIVATE
    SIMULATION
)
```

硬件：

不定义。

---

ROS2里面也大量使用这种思想。

例如：

```cpp
#ifdef ROS_DISTRO_JAZZY
...
#endif
```

---

# 14.12 本章总结

## 添加编译参数：

```cmake
target_compile_options(
    target
    PRIVATE
    -Wall
)
```

---

## 添加宏：

```cmake
target_compile_definitions(
    target
    PRIVATE
    DEBUG_MODE
)
```

等价：

```bash
-DDEBUG_MODE
```

---

## C++标准：

```cmake
target_compile_features(
    target
    PRIVATE
    cxx_std_17
)
```

---

## 核心思想：

不要：

```cmake
set(CMAKE_CXX_FLAGS ...)
```

全局污染。

现代 CMake：

```text
target
 |
 ├── source
 ├── include
 ├── libraries
 ├── compile options
 └── definitions
```

所有东西围绕 target 管理。

---

下一章：

# 第15章：Debug / Release、构建类型、安装与打包

会讲：

* `CMAKE_BUILD_TYPE`
* Debug/Release区别
* `cmake --build`
* `install()`
* `cmake --install`
* 如何生成类似系统库的安装结构

这一章之后，你基本具备维护真实 C++ 工程 CMake 的能力。
