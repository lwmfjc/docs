---
title: 08_target_link_libraries深入_库、链接、依赖关系
description: 08_target_link_libraries深入_库、链接、依赖关系
categories:
  - 学习
tags:
  - 单片机
  - STM32
  - 江科大
date: 2026-09-10T19:01:28+08:00
lastmod: 2026-09-10T19:01:28+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
***第8章：target_link_libraries 深入 —— 库、链接、依赖关系***

这一章会把你之前问的：

> OpenCV target是什么？
>
> .so怎么和robot连接？
>
> target是不是虚拟目标？

这些问题彻底串起来。

# 8.1 为什么需要库？

先看一个简单程序。


目录：

```
Robot

├── main.cpp
└── motor.cpp
└── motor.h
```

main.cpp：

```cpp
#include "motor.h"

int main()
{
    motor_run();

    return 0;
}
```

motor.cpp：

```cpp
#include <iostream>


void motor_run()
{
    std::cout<<"motor run"<<std::endl;
}
```

motor.h：

```cpp 
void motor_run();
```

编译：

```bash
g++ main.cpp motor.cpp -o robot
```

没问题。

流程：

```
main.cpp
     |
     ↓
 main.o


motor.cpp
     |
     ↓
 motor.o


main.o + motor.o

       ↓

    robot
```

---

但是如果：

你的项目越来越大：

```
Robot

src
├── main.cpp
├── motor.cpp
├── sensor.cpp
├── camera.cpp
├── navigation.cpp
├── mapping.cpp
......
```

几十万个文件怎么办？

所以需要拆：

```
robot程序

       |
       |
       ↓

-----------------
|       |       |
motor  sensor  vision
库      库      库
```

---

# 8.2 什么是库？

库本质：

> 一组已经编译好的代码，可以被其他程序使用。

例如：

OpenCV：

```
libopencv_core.so
```

里面：

```
Mat类

图像处理函数

矩阵计算代码
```

---

你的程序：

```cpp
#include <opencv2/opencv.hpp>


int main()
{
    cv::Mat img;
}
```

你的代码里面没有：

```
Mat实现代码
```

它在哪里？

在：

```
libopencv_core.so
```

---

# 8.3 库的两种形式

## 1. 静态库 Static Library

后缀：

Linux：

```
.a
```

Windows：

```
.lib
```

例如：

```
libmotor.a
```

特点：

编译链接时：

直接复制进去。

流程：

```
main.o

+

libmotor.a

↓

robot
```

生成：

```
robot
```

**运行时：**

**不需要这个库。**

---

## 2. 动态库 Shared Library

后缀：

Linux:

```
.so
```

Windows:

```
.dll
```

例如：

```
libopencv_core.so
```

特点：

运行时加载。

流程：

编译：

```
main.o
     |
     |
     ↓

robot
```

运行：

```
robot

  |
  |
  ↓

libopencv_core.so
```

---

# 8.4 CMake创建库

之前：

创建程序：

```cmake
add_executable(
    robot

    main.cpp
)
```

创建库：

```cmake
add_library(
    motor

    motor.cpp
)
```

例如：

目录：

```
Robot

├── CMakeLists.txt
├── main.cpp
├── motor.cpp
└── motor.h
```

CMake：

```cmake
cmake_minimum_required(VERSION 3.20)

project(Robot)


add_library(
    motor

    motor.cpp
)


add_executable(
    robot

    main.cpp
)
```

现在产生两个target：

```
target:

motor

robot
```

注意：

这里：

```
motor
```

也是target。

---

# 8.5 target_link_libraries

现在问题：

robot使用motor。

那么：

```cmake
target_link_libraries(
    robot

    motor
)
```

意思：

建立关系：

```
robot

依赖

motor
```

完整：

```cmake
add_library(
    motor

    motor.cpp
)


add_executable(
    robot

    main.cpp
)


target_link_libraries(
    robot

    motor
)
```

---

CMake内部理解：

```
              robot target


                    |
                    |
                  depends


                    ↓


              motor target
```

---

# 8.6 它实际生成什么？

假设：

Linux。

执行：

```bash
cmake ..
make
```

过程：

先：

```
motor.cpp
   ↓ 编译
motor.o
   ↓ 打包
libmotor.a
```


然后：

```
main.cpp

↓编译

main.o
```

最后：

```
main.o

+

libmotor.a

↓ 链接

robot
```

---

# 8.7 为什么不用直接写文件路径？

例如：

你也可以：

```cmake
target_link_libraries(
    robot

    /usr/lib/libopencv.so
)
```

可以。

但是不好。

因为你绑定死了：

```
/usr/lib
```

换电脑：

可能：

```
/opt/opencv/lib
```

或者：

```
/usr/local/lib
```

路径变了。

---

现代CMake：

推荐：

```
target
依赖
target
```

例如：

```cmake
find_package(OpenCV REQUIRED)


target_link_libraries(
    robot

    OpenCV::opencv_core
)
```

CMake自己知道：

```
OpenCV::opencv_core

对应：

libopencv_core.so

头文件：

/usr/include/opencv4

依赖：

pthread
zlib
...
```

---

# 8.8 一个重要概念：target之间形成图

大型项目实际上是一张图。

例如ROS2：

```
                 robot


                  |
       ---------------------

       |          |          |

    camera     lidar      motor


       |          |

    OpenCV      PCL
```

CMake做的事情：

就是分析：

```
谁依赖谁
```

然后决定：

```
先编译谁
后链接谁
```

---

# 8.9 回到你之前STM32项目

例如：

你的STM32：

```
STM32Project

├── main.c
├── motor.c
├── uart.c
└── pid.c
```

以后可以设计：

```
stm32_app target


       |
       |
       ↓


motor_lib target

uart_lib target

pid_lib target
```

CMake：

```cmake
add_library(
    motor
    motor.c
)


add_library(
    uart
    uart.c
)


add_executable(
    stm32_app
    main.c
)


target_link_libraries(
    stm32_app

    motor
    uart
)
```

这样结构更接近工业项目。

---

# 8.10 本章重点总结

记住：

## 创建库

```cmake
add_library(
    名字

    源文件
)
```

例如：

```cmake
add_library(
    motor

    motor.cpp
)
```

---

## 程序依赖库

```cmake
target_link_libraries(
    程序

    库
)
```

例如：

```cmake
target_link_libraries(
    robot

    motor
)
```

关系：

```
robot
 |
 |
依赖
 |
 ↓
motor
```

---

## target不是文件

这里：

```
motor
```

不是：

```
motor文件夹
```

也不是：

```
libmotor.a
```

而是：

```
CMake中的一个构建对象
```

最后它可能产生：

```
libmotor.a
```

或者：

```
libmotor.so
```

---

到这里，你已经理解了现代 CMake 的三大核心：

```
target_sources
        |
        ↓
这个target有哪些源码


target_include_directories
        |
        ↓
这个target去哪找头文件


target_link_libraries
        |
        ↓
这个target依赖哪些库
```

下一章进入：

# 第9章：PRIVATE / PUBLIC / INTERFACE（现代CMake最重要的设计）

这也是很多人第一次看 ROS2、OpenCV、Qt CMakeLists 时最容易卡住的地方。

例如：

```cmake
target_link_libraries(
    robot

    PRIVATE
    OpenCV::opencv_core
)
```

为什么有时候 PRIVATE？

为什么有时候 PUBLIC？

这个会直接决定依赖是否传递。你之前问“target是不是虚拟目标”，这里会进一步深入 target 内部属性。
