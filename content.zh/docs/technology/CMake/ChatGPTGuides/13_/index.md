---
title: 13_
description: 13_
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

CMake 需要先通过：

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
    OpenCV::opencv_core
)
```

为什么？

因为：

```text
OpenCV::opencv_core
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
OpenCV::opencv_core
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

OpenCV::opencv_core


这个target来自系统
```

---

# 13.6 为什么要叫 target？

因为它可以携带很多信息：

例如：

```text
OpenCV::opencv_core

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


add_executable(
    opencv_test
    main.cpp
)


target_link_libraries(
    opencv_test
    PRIVATE
    OpenCV::opencv_core
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

OpenCV::opencv_core
```

---

编译时：

CMake 自动知道：

```text
-I/usr/include/opencv4

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

# 13.11 `xxx::yyy` 为什么经常出现？

你以后会看到：

```cmake
Qt6::Widgets

OpenCV::opencv_core

Eigen3::Eigen

Boost::filesystem
```

这种格式。

例如：

```cmake
target_link_libraries(
    app
    PRIVATE
    Qt6::Widgets
)
```

不要理解成：

```text
Qt6文件夹里面的Widgets
```

它是：

> 一个 target 名字。

---

这个：

```text
::
```

只是 CMake 的命名习惯。

通常表示：

```text
命名空间::target
```

例如：

```text
OpenCV::opencv_core

命名空间:
OpenCV

target:
opencv_core
```

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
    OpenCV::opencv_core
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

OpenCV::opencv_core
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
OpenCV::opencv_core
```

然后：

```cmake
target_link_libraries(
    robot
    PRIVATE
    OpenCV::opencv_core
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
