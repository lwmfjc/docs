---
title: 15_Debug、Release、构建类型、安装与打包
description: 15_Debug、Release、构建类型、安装与打包
categories:
  - 学习
tags:
  - CMake
  - ChatGPTGuides
date: 2026-09-15T18:56:56+08:00
lastmod: 2026-09-15T18:56:56+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
***第15章：Debug / Release、构建类型、安装与打包***

前面学习了：

* target
* 库
* 第三方依赖
* 编译选项
* 宏定义

现在进入实际工程非常常见的一部分：

> 一个项目如何生成 Debug 版本、Release 版本，并且如何安装发布。

---

# 15.1 为什么需要 Debug 和 Release？

假设一个机器人程序：

```text
robot
```

开发阶段：

你希望：

* 可以断点调试
* 查看变量
* 保留错误信息

运行阶段：

你希望：

* 速度快
* 文件小
* 性能高

所以需要不同构建方式。

---

## Debug版本

特点：

```text
调试友好
```

通常：

```text
-g
-O0
```

含义：

### `-g`

生成调试信息：

```text
源码
  |
  ↓
机器码
  |
  ↓
保留对应关系
```

方便：

* gdb
* VS Code Debug

---

### `-O0`

关闭优化：

例如：

代码：

```cpp
int a = 10;
int b = 20;
int c = a+b;
```

优化关闭：

机器码接近源码。

方便调试。

---

## Release版本

特点：

```text
运行效率优先
```

通常：

```text
-O2
```

或者：

```text
-O3
```

编译器会：

* 删除无用代码
* 调整指令顺序
* 内联函数

提高性能。

---

# 15.2 CMake中的构建类型

CMake提供：

```text
CMAKE_BUILD_TYPE
```

常见：

| 类型             | 用途      |
| -------------- | ------- |
| Debug          | 开发调试    |
| Release        | 发布      |
| RelWithDebInfo | 优化+调试信息 |
| MinSizeRel     | 最小体积    |

---

例如：

Debug：

```bash
cmake -S . -B build \
-DCMAKE_BUILD_TYPE=Debug
```

> 执行后，CMake 会：
> 1. 检查编译器
> 2. 查找依赖
> 3. 生成构建系统（Makefile / Ninja文件）
> 4. 把 Debug 配置写入 build

Release：

```bash
cmake -S . -B build \
-DCMAKE_BUILD_TYPE=Release
```

> 以上讲的是cmake配置阶段（configure）：使用当前目录 . 里的 CMakeLists.txt，生成构建目录 build，并设置构建类型为 Debug。

---

> 构建阶段（build）:让 CMake 调用已经生成好的构建系统，在 build 目录里面编译。

生成：

```bash
cmake --build build
```

- cmake -S -B → 让 CMake 生成构建系统
- cmake --build → 让 CMake 调用构建系统
- make → 直接调用某一种构建系统

---

# 15.3 查看当前构建类型

CMake：

```cmake
#配置的时候会出现的信息，如果没有指定-DCMAKE_BUILD_TYPE，默认为空
message(
    "Build type=${CMAKE_BUILD_TYPE}"
)
```

运行：

```bash
#这是属于 配置阶段（Configure / Generate）。（传统方式）
## 下面输出显示 Debug 是因为 build 目录中的 CMakeCache.txt
# 已经保存了 CMAKE_BUILD_TYPE=Debug 配置（因为之前使用过cmake -S . 
#-B build -DCMAKE_BUILD_TYPE=Release 
cmake ..
#相当于下面这个（现代方式）
#cmake -S . -B build
```

输出：

```text
Build type=Debug
```

---

# 15.4 根据Debug/Release执行不同代码

例如：

```cmake
if(CMAKE_BUILD_TYPE STREQUAL "Debug")

    message("debug build")

else()

    message("release build")

endif()
```

---

实际例子：

Debug开启日志：

```cmake
if(CMAKE_BUILD_TYPE STREQUAL "Debug")

    target_compile_definitions(
        robot
        PRIVATE
        ENABLE_LOG
    )

endif()
```

代码：

```cpp
#ifdef ENABLE_LOG

std::cout<<"debug log";

#endif
```

---

# 15.5 多配置生成器

这里补充一个概念。

Linux：

通常：

```bash
cmake ..
```

选择一次。

例如：

```text
build/
 |
 Debug
```

或者：

```text
Release
```

---

但是 Visual Studio：

可以一次生成：

```text
Debug
Release
RelWithDebInfo
```

例如：

```bash
cmake --build . --config Release
```

指定。

---

# 15.6 不推荐手写优化参数

例如：

```cmake
target_compile_options(
    robot
    PRIVATE
    -O3
)
```

可以。

但是不推荐作为主要方式。

原因：

你破坏了 CMake 的构建模型。

推荐：

```bash
cmake \
-DCMAKE_BUILD_TYPE=Release ..
```

让 CMake 自动处理：

Release：

```text
-O3
```

Debug：

```text
-g -O0
```

---

# 15.7 install() —— 安装项目

现在：

你的项目：

```text
Robot

├── CMakeLists.txt
├── src
├── include
└── build
```

编译后：

```text
build/
└── robot
```

但是别人不知道：

这个文件应该放哪里。

所以需要：

安装规则。

---

## install目标

例如：

```cmake
install(
    TARGETS
    robot
)
```

意思：

安装：

```text
robot
```

这个target。

---

但是安装到哪里？

---

# 15.8 CMAKE_INSTALL_PREFIX

默认：

Linux：

```text
/usr/local
```

例如：

安装：

```text
/usr/local/bin/robot
```

---

修改：

```bash
cmake .. \
-DCMAKE_INSTALL_PREFIX=/opt/robot
```

那么：

安装：

```text
/opt/robot
```

---

# 15.9 安装可执行文件

完整：

```cmake
add_executable(
    robot
    main.cpp
)


install(
    TARGETS
    robot
    DESTINATION
    bin
)
```

执行：

```bash
cmake --install build
```

结果：

```text
/usr/local/bin/robot
```

---

# 15.10 安装库

例如：

前面：

```cmake
add_library(
    motor
    SHARED
    motor.cpp
)
```

安装：

```cmake
install(
    TARGETS
    motor
    LIBRARY DESTINATION lib
)
```

结果：

```text
/usr/local/lib/

libmotor.so
```

---

# 15.11 安装头文件

假设：

```text
include/

motor.hpp
```

CMake：

```cmake
install(
    DIRECTORY
    include/
    DESTINATION
    include
)
```

结果：

```text
/usr/local/include/

motor.hpp
```

---

# 15.12 一个真实库的安装结构

例如：

安装：

```text
/usr/local
|
├── bin
│   └── robot
│
├── lib
│   └── libmotor.so
│
└── include
    └── motor.hpp
```

这就是 Linux 常见软件布局。

---

# 15.13 为什么ROS2大量用install？

你之前学习 ROS2：

例如：

```bash
colcon build
```

之后：

```bash
source install/setup.bash
```

这里：

```text
install/
```

就是 CMake install 的思想。

ROS2 package：

编译：

```text
build/
```

生成：

```text
install/
```

运行时：

从：

```text
install/
```

寻找：

* 节点
* 库
* 环境变量

---

# 15.14 本章总结

## Debug:

```bash
cmake .. \
-DCMAKE_BUILD_TYPE=Debug
```

特点：

* -g
* -O0
* 方便调试

---

## Release:

```bash
cmake .. \
-DCMAKE_BUILD_TYPE=Release
```

特点：

* 优化
* 性能优先

---

## 安装：

可执行文件：

```cmake
install(
 TARGETS robot
 DESTINATION bin
)
```

库：

```cmake
install(
 TARGETS motor
 DESTINATION lib
)
```

头文件：

```cmake
install(
 DIRECTORY include/
 DESTINATION include
)
```

---

到这里：

你已经学习了 CMake 绝大部分日常开发需要的内容：

1. target思想 ✅
2. 多目录工程 ✅
3. 库管理 ✅
4. 第三方依赖 ✅
5. 编译配置 ✅
6. 安装发布 ✅

下一章就是最后一章：

# 第16章：综合实战 —— 一个接近真实项目的 CMake 工程

会把前面的知识串起来：

```text
RobotProject

├── CMakeLists.txt
│
├── app
│   └── main.cpp
│
├── motor
│   ├── include
│   └── src
│
├── sensor
│   ├── include
│   └── src
│
├── third_party
│
└── install
```

模拟一个小型机器人项目的 CMake 组织方式。你学完这一章，基本可以看懂 ROS2、OpenCV 等项目里的 CMakeLists.txt 结构。
