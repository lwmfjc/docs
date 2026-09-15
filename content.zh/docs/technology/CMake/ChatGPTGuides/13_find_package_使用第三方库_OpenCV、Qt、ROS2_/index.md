---
title: 13_find_package_使用第三方库_OpenCV、Qt、ROS2_
description: 13_find_package_使用第三方库_OpenCV、Qt、ROS2_
categories:
  - 学习
tags:
  - CMake
  - ChatGPTGuides
date: 2026-09-15T12:00:45+08:00
lastmod: 2026-09-15T12:00:45+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
***第13章：`find_package()` —— 使用第三方库（OpenCV、Qt、ROS2）***

前面 1～12 章，你一直是在学习：

> **如何创建自己的 target**

例如：

```cmake
add_library(motor)
add_executable(robot)

target_link_libraries(
    robot
    PRIVATE
    motor
)
```

但是实际开发中，大量代码不是你写的。

例如：

* OpenCV
* Eigen
* Qt
* Boost
* ROS2
* CUDA
* PCL

你不会把它们源码复制到你的项目里。

你需要：

> 找到已经安装好的库，并告诉 CMake 怎么使用。

这就是：

```cmake
find_package()
```

---

# 13.1 先回顾一个问题

你之前问过：

```cmake
target_link_libraries(
    robot
    OpenCV
)
```

类似这种：

> OpenCV 是一个文件夹吗？
>
> CMake 怎么知道去哪里找？

答案：

**它不是靠猜。**

CMake 需要**先通过**：

```cmake
find_package()
```

找到 OpenCV 的信息。

---

# 13.2 第三方库实际是什么？

以 OpenCV 为例。

安装：

```bash
sudo apt install libopencv-dev
```

之后系统里面可能有：

头文件：

```text
/usr/include/opencv4/
```

例如：

```text
opencv2/opencv.hpp
...
#里头还有一堆.hpp
```

库文件：

```text
/usr/lib/x86_64-linux-gnu/
```

例如：

```text
libopencv_core.so
libopencv_imgproc.so
libopencv_highgui.so
...
#里头还有一堆.so
```

结构：

```text
OpenCV
│
├── 头文件
│     ↓
│   .hpp
│
├── 库文件
│     ↓
│   .so
│
└── CMake配置文件
      ↓
    OpenCVConfig.cmake
```

关键是最后这个：

```text
OpenCVConfig.cmake
```

## OpenCVConfig.cmake部分内容

```cmake
╭─ ∅ /usr/lib/x86_64-linux-gnu/cmake/opencv4
╰─❯ cat OpenCVConfig.cmake
# ===================================================================================
#  The OpenCV CMake configuration file
#
#             ** File generated automatically, do not modify **
#
#  Usage from an external project:
#    In your CMakeLists.txt, add these lines:
#
#    find_package(OpenCV REQUIRED)
#    include_directories(${OpenCV_INCLUDE_DIRS}) # Not needed for CMake >= 2.8.11
#    target_link_libraries(MY_TARGET_NAME ${OpenCV_LIBS})
#
#    Or you can search for specific OpenCV modules:
#
#    find_package(OpenCV REQUIRED core videoio)
#
#    You can also mark OpenCV components as optional:

#    find_package(OpenCV REQUIRED core OPTIONAL_COMPONENTS viz)
#
#    If the module is found then OPENCV_<MODULE>_FOUND is set to TRUE.
#
#    This file will define the following variables:
#      - OpenCV_LIBS                     : The list of all imported targets for OpenCV modules.
#      - OpenCV_INCLUDE_DIRS             : The OpenCV include directories.
#      - OpenCV_COMPUTE_CAPABILITIES     : The version of compute capability.
#      - OpenCV_ANDROID_NATIVE_API_LEVEL : Minimum required level of Android API.
#      - OpenCV_VERSION                  : The version of this OpenCV build: "4.6.0"
#      - OpenCV_VERSION_MAJOR            : Major version part of OpenCV_VERSION: "4"
#      - OpenCV_VERSION_MINOR            : Minor version part of OpenCV_VERSION: "6"
#      - OpenCV_VERSION_PATCH            : Patch version part of OpenCV_VERSION: "0"
#      - OpenCV_VERSION_STATUS           : Development status of this build: ""
#
#    Advanced variables:
#      - OpenCV_SHARED                   : Use OpenCV as shared library
#      - OpenCV_INSTALL_PATH             : OpenCV location
#      - OpenCV_LIB_COMPONENTS           : Present OpenCV modules list
#      - OpenCV_USE_MANGLED_PATHS        : Mangled OpenCV path flag
#
#    Deprecated variables:
#      - OpenCV_VERSION_TWEAK            : Always "0"
#
# ===================================================================================

# ======================================================
#  Version variables:
# ======================================================
SET(OpenCV_VERSION 4.6.0)
SET(OpenCV_VERSION_MAJOR  4)
SET(OpenCV_VERSION_MINOR  6)
SET(OpenCV_VERSION_PATCH  0)
SET(OpenCV_VERSION_TWEAK  0)
SET(OpenCV_VERSION_STATUS "")

include(FindPackageHandleStandardArgs)

if(NOT CMAKE_VERSION VERSION_LESS 2.8.8
    AND OpenCV_FIND_COMPONENTS  # prevent excessive output
)
  # HANDLE_COMPONENTS was introduced in CMake 2.8.8
  list(APPEND _OpenCV_FPHSA_ARGS HANDLE_COMPONENTS)
  
#....还有一堆没有截取出来
```

---

# 13.3 `find_package()` 做什么？

例如：

```cmake
find_package(OpenCV REQUIRED)
```

意思：

> CMake，请帮我找到 OpenCV，并加载它的信息。

它会寻找类似：

```text
OpenCVConfig.cmake
```

或者：

```text
opencv-config.cmake
```

文件。

里面记录：

```text
OpenCV在哪里？

头文件在哪里？

库文件在哪里？

有哪些target？
```

---

# 13.4 找到之后发生什么？

例如：

```cmake
find_package(OpenCV REQUIRED)
```

成功后，CMake 获得：

```text
OpenCV_INCLUDE_DIRS

OpenCV_LIBS
```

等变量。

以前老式写法：

```cmake
target_include_directories(
    robot
    PRIVATE
    ${OpenCV_INCLUDE_DIRS}
)


target_link_libraries(
    robot
    ${OpenCV_LIBS}
)
```

---

但是现代 CMake 更推荐：

```cmake
target_link_libraries(
    robot
    PRIVATE
    opencv_core
)
```

> 校正：没有 `OpenCV::opencv_core` 这种 target 用法时，可以使用 opencv_core（无命名空间 target） ~~只依赖一个~~ 或者 ${OpenCV_LIBS} / ${OpenCV_LIBRARIES}（变量方式） ~~会依赖变量展开的所有~~ 这两种。

为什么？

因为：

```text
opencv_core
```

本身就是一个 target。

这又回到了你前面学的：

> CMake核心思想：target

---

# 13.5 什么是 imported target？

这是本章重点。

你前面创建：

```cmake
add_library(motor)
```

叫：

> 自己创建的 target

英文：

```
build target
```

---

但是：

```cmake
opencv_core
```

不是你创建的。

它来自：

```cmake
find_package(OpenCV)
```

叫：

> imported target（导入目标）

---

关系：

```text
你的项目

    robot
      |
      |
      ↓

opencv_core


这个target来自系统
```

---

# 13.6 为什么要叫 target？

因为它可以携带很多信息：

例如：

```text
opencv_core

里面保存：

include目录:
/usr/include/opencv4

库:
/usr/lib/libopencv_core.so

编译选项:
xxx

依赖:
xxx
```

所以你不用手动写：

```cmake
-I/usr/include/opencv4

-lopencv_core
```

---

这就是现代 CMake 强大的地方：

> 依赖不是文件路径，而是 target。

---


# 13.7 一个完整 OpenCV 示例

项目：

```text
OpenCVTest/

├── CMakeLists.txt
└── main.cpp
```

main.cpp:

```cpp
#include <opencv2/opencv.hpp>

int main()
{
    cv::Mat img;

    return 0;
}
```

---

CMakeLists.txt：

```cmake
cmake_minimum_required(VERSION 3.20)

project(OpenCVTest)

find_package(OpenCV REQUIRED)

#显示变量表示的所有依赖名
#message(STATUS "OpenCV_LIBS = ${OpenCV_LIBS}")

add_executable(
        opencv_test
        main.cpp
)

target_link_libraries(
        opencv_test
        PRIVATE
        opencv_core
#       ${OpenCV_LIBS}
#       ${OpenCV_LIBRARIES}
)
```

流程：

---

第一步：

```cmake
find_package(OpenCV REQUIRED)
```

找到：

```text
OpenCV
```

---

第二步：

创建：

```text
opencv_test
```

target

---

第三步：

连接：

```text
opencv_test

↓

opencv_core
```

---

编译时：

CMake 自动知道：

```text
#-I表示到哪里找头文件
-I/usr/include/opencv4

#-lopencv_core 表示链接名为 opencv_core 的库，通常对应 libopencv_core.so 或 libopencv_core.a。【但是我觉得这里可能不止是一个文件，而是好几个】
-lopencv_core
```

---

# 13.8 `REQUIRED`是什么意思？

例如：

```cmake
find_package(OpenCV REQUIRED)
```

表示：

> 必须找到，否则 CMake 配置失败。

如果没有：

输出：

```text
Could NOT find OpenCV
```

然后停止。

---

如果：

```cmake
find_package(OpenCV)
```

没有：

程序继续。

你可以：

```cmake
if(OpenCV_FOUND)

endif()
```

判断。

## 完整解释

执行：

```
find_package(OpenCV)
```

之后，CMake 会自动设置一个变量：

```
OpenCV_FOUND
```

它的值类似：

```
OpenCV_FOUND = TRUE
```

或者：

```
OpenCV_FOUND = FALSE
```

然后：

```
if(OpenCV_FOUND)
```

相当于：

```
如果 OpenCV_FOUND 为真
    执行这里
否则
    执行 else
```
例如：
```
find_package(OpenCV)

if(OpenCV_FOUND)
    add_executable(
        opencv_test
        main.cpp
    )

    target_link_libraries(
        opencv_test
        PRIVATE
        opencv_core
    )
endif()
```

逻辑：

```
查找 OpenCV

      |
      |
      v

找到？
  |
  +---- 是
  |       |
  |       v
  |   创建程序并链接 OpenCV
  |
  |
  +---- 否
          |
          v
      什么都不做
```

---

# 13.9 `find_package()` 两种模式

CMake 有两种寻找方式。

## 模式1：Config模式（现代）

寻找：

```text
xxxConfig.cmake
```

例如：

```text
OpenCVConfig.cmake
Qt6Config.cmake
Eigen3Config.cmake
```

现在大量使用。

---

## 模式2：Module模式

寻找：

```text
FindXXX.cmake
```

例如：

```text
FindOpenGL.cmake
```

CMake 自带很多。

---

简单理解：

```text
Config模式

库作者提供


Module模式

CMake提供
```

---

# 13.10 为什么 ROS2 里面大量出现 find_package？

例如 ROS2：

```cmake
find_package(rclcpp REQUIRED)
```

意思：

找到：

```text
rclcpp
```

然后：

```cmake
ament_target_dependencies(
    robot_node
    rclcpp
)
```

本质：

也是：

```text
robot_node

↓

rclcpp target
```

---

所以 ROS2 的 CMake：

看起来特殊：

```cmake
ament_target_dependencies()
```

但是底层思想仍然是：

```text
target依赖关系
```

---
好的，这一节需要修正。我把 **第13.11节**重新整理，删除 `OpenCV::opencv_core` 的错误示例。

先说明修正：

之前写：

```cmake
OpenCV::opencv_core
```

作为 OpenCV 示例是不严谨的。

你的环境：

* Ubuntu 24.04
* apt 安装
* OpenCV 4.6.0

实际提供的是：

```cmake
opencv_core
```

以及：

```cmake
${OpenCV_LIBS}
```

OpenCV 官方示例也是使用：

```cmake
target_link_libraries(opencv_test PRIVATE ${OpenCV_LIBS})
```

而不是 `OpenCV::opencv_core`。([GitHub][1])

---

# 13.11节 `xxx::yyy` 为什么经常出现？

在 CMake 中，你经常会看到：

```cmake
Qt6::Widgets

Eigen3::Eigen

Boost::filesystem
```

这种形式。

例如：

```cmake
target_link_libraries(
    app
    PRIVATE
    Qt6::Widgets
)
```

这里：

```text
Qt6::Widgets
```

不是文件路径。

它是：

> 一个 CMake target 名称。

---

## 13.11.1 `::` 表示什么？

通常：

```text
命名空间::target
```

例如：

```text
Qt6::Widgets
```

可以理解为：

```text
Qt6
 |
 └── Widgets
```

但是它不是目录关系。

它只是一个名字。

---

## 13.11.2 target 可以来自哪里？

前面学习过：

自己创建：

```cmake
add_library(
    motor
)
```

得到：

```text
motor
```

target。

---

第三方库：

例如：

```cmake
find_package(Qt6 REQUIRED)
```

之后可能得到：

```cmake
Qt6::Widgets
```

这种 imported target。

关系：

```
你的程序

robot
 |
 |
 ↓

Qt6::Widgets

(来自Qt安装)
```

---

## 13.11.3 但是 OpenCV 是特殊情况

OpenCV 不应该写：

```cmake
OpenCV::opencv_core
```

作为通用示例。

常见写法：

### 方法1：使用 OpenCV_LIBS（推荐兼容）

```cmake
find_package(OpenCV REQUIRED)


target_link_libraries(
    opencv_test
    PRIVATE
    ${OpenCV_LIBS}
)
```

OpenCV 的 CMake 配置会生成：

```text
OpenCV_LIBS
```

这个变量。

里面类似：

```text
opencv_core
opencv_imgproc
opencv_highgui
...
```

([GitHub][2])

---

### 方法2：指定模块

如果只需要核心模块：

```cmake
find_package(OpenCV REQUIRED)


target_link_libraries(
    opencv_test
    PRIVATE
    opencv_core
)
```

CMake 最终会交给链接器：

```bash
-lopencv_core
```

然后寻找：

```text
libopencv_core.so
```

或者：

```text
libopencv_core.a
```

---

## 13.11.4 为什么不能认为所有库都是 `xxx::yyy`？

错误理解：

```
find_package()
        |
        ↓
一定得到
xxx::yyy
```

实际：

```
find_package()

可能得到：

① imported target

例如：
Qt6::Widgets


② 普通target

例如：
opencv_core


③ 变量

例如：
OpenCV_LIBS
```

不同库设计不同。

---

## 13.11.5 如何判断一个库有什么 target？

不要猜。

查看：

```cmake
if(TARGET xxx::yyy)
    message("exists")
endif()
```

例如：

```cmake
if(TARGET OpenCV::opencv_core)
    message("OpenCV target exists")
else()
    message("not exists")
endif()
```

你的 OpenCV 4.6.0：

结果：

```text
not exists
```

---

## 13.11.6 本节重新总结

记住：

### CMake target

可能是：

自己创建：

```cmake
add_library(motor)
```

得到：

```
motor
```

---

第三方库：

可能：

```
Qt6::Widgets
```

---

也可能：

```
opencv_core
```

---

或者：

变量：

```
${OpenCV_LIBS}
```

---

不要死记：

```
所有库都是 xxx::yyy
```

正确理解：

> CMake 的核心是 target，但是不同第三方库暴露 target 的方式不同。

---

# 13.12 为什么不直接写路径？

旧方式：

```cmake
target_link_libraries(
    robot
    /usr/lib/libopencv_core.so
)
```

问题：

换电脑：

```text
/usr/lib
```

可能不存在。

Windows：

```text
C:/opencv/lib
```

又不同。

---

现代方式：

```cmake
find_package(OpenCV)

target_link_libraries(
    robot
    opencv_core
)
```

优势：

CMake自己处理：

* Linux
* Windows
* macOS
* Debug
* Release
* 不同安装位置

---

# 13.13 这一章和前面的知识如何连接？

现在完整链路：

```text
第三方库

OpenCV
  |
  |
find_package()
  |
  |
得到 target

opencv_core
  |
  |
target_link_libraries()
  |
  |
你的target
```

也就是说：

你的项目：

```text
robot

↓

motor

↓

OpenCV
```

全部都是：

```text
target之间的关系
```

---

# 13.14 本章核心记忆

记住下面几句话即可：

### ① 第三方库不是靠文件夹找

错误理解：

```
CMake扫描目录找OpenCV
```

正确：

```
find_package()
寻找库提供的CMake配置
```

---

### ② 现代 CMake 不喜欢手写路径

少写：

```cmake
/usr/lib/libxxx.so
```

多写：

```cmake
xxx::yyy
```

---

### ③ find_package() 的结果通常是 target

例如：

```cmake
find_package(OpenCV REQUIRED)
```

得到：

```cmake
opencv_core
```

然后：

```cmake
target_link_libraries(
    robot
    PRIVATE
    opencv_core
)
```

---

### ④ CMake核心思想没有变

从第6章到现在：

一直是：

```text
target
  |
  |
依赖关系
  |
  |
构建系统
```

---

下一章：

# 第14章：编译选项与宏定义 —— `target_compile_options()`、`target_compile_definitions()`

这一章会讲：

* `-Wall`
* `-O2`
* `-g`
* `DEBUG宏`
* `#ifdef`
* 为什么现代 CMake 不推荐全局 `add_definitions()`

这些内容会直接连接你以后：

* C++
  工程
* STM32
* ROS2
* OpenCV项目

的实际开发。
