---
title: 16_综合实战_一个接近真实项目的CMake工程
description: 16_综合实战_一个接近真实项目的CMake工程
categories:
  - 学习
tags:
  - CMake
  - ChatGPTGuides
date: 2026-09-16T15:08:33+08:00
lastmod: 2026-09-16T15:08:33+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
***第16章：综合实战 —— 一个接近真实项目的 CMake 工程***  

前面15章我们学习的是**单个知识点**：

* target
* library
* include
* link
* find_package
* install

但是实际项目不会把所有代码放在一个 `main.cpp` 里。

真实 C++ 项目通常类似：

```text
RobotProject

├── CMakeLists.txt
│
├── app
│   └── main.cpp
│
├── motor
│   ├── CMakeLists.txt
│   ├── include
│   │   └── motor.hpp
│   └── src
│       └── motor.cpp
│
├── sensor
│   ├── CMakeLists.txt
│   ├── include
│   │   └── sensor.hpp
│   └── src
│       └── sensor.cpp
│
└── build
```

这就是 ROS2、OpenCV、很多工业项目的组织方式。

---

# 16.1 项目需求

假设我们开发一个机器人程序：

有两个模块：

## 电机模块

```text
motor
```

负责：

```cpp
Motor::move()
```

---

## 传感器模块

```text
sensor
```

负责：

```cpp
Sensor::read()
```

---

主程序：

```text
robot_app
```

调用：

```cpp
Motor
Sensor
```

结构：

```text
            robot_app

              |
        --------------
        |            |

     motor        sensor

```

---

# 16.2 创建目录

完整：

```bash
mkdir RobotProject

cd RobotProject


mkdir app

mkdir motor
mkdir motor/include
mkdir motor/src

mkdir sensor
mkdir sensor/include
mkdir sensor/src
```

最终：

```text
RobotProject

├── app
│
├── motor
│   ├── include
│   └── src
│
└── sensor
    ├── include
    └── src
```

---

# 16.3 motor模块

## motor/include/motor.hpp

```cpp
#pragma once


class Motor
{

public:

    void move();

};
```

---

## motor/src/motor.cpp

```cpp
#include "motor.hpp"

#include <iostream>


void Motor::move()
{
    std::cout
        << "motor moving"
        << std::endl;
}
```

---

现在：

motor本身应该是一个库。

所以：

创建：

```
motor/CMakeLists.txt
```

---

# 16.4 motor自己的CMakeLists

```cmake
add_library(
    motor
    STATIC
    src/motor.cpp
)


target_include_directories(
    motor
    PUBLIC
    include
)
```

解释：

---

## 创建库

```cmake
add_library(
    motor
    STATIC
    src/motor.cpp
)
```

生成：

```text
libmotor.a
```

---

## 添加头文件路径

```cmake
target_include_directories(
    motor
    PUBLIC
    include #相当于${CMAKE_CURRENT_SOURCE_DIR}/include
)
```

为什么 PUBLIC？

因为：

motor.cpp：

需要：

```cpp
#include "motor.hpp"
```

使用 motor 的：

```cpp
main.cpp
```

也需要：

```cpp
#include "motor.hpp"
```

所以传播。

---

# 16.5 sensor模块

类似。

## sensor/include/sensor.hpp

```cpp
#pragma once


class Sensor
{

public:

    int read();

};
```

---

## sensor/src/sensor.cpp

```cpp
#include "sensor.hpp"


int Sensor::read()
{
    return 100;
}
```

---

## sensor/CMakeLists.txt

```cmake
add_library(
    sensor
    STATIC
    src/sensor.cpp
)


target_include_directories(
    sensor
    PUBLIC
    include
)
```

---

# 16.6 根目录 CMakeLists

现在：

顶层：

```
RobotProject/CMakeLists.txt
```

负责：

管理子模块。

写：

```cmake
cmake_minimum_required(VERSION 3.20)


project(RobotProject)


add_subdirectory(
    motor
)


add_subdirectory(
    sensor
)


add_subdirectory(
    app
)
```

---

这里使用：

第11章：

```cmake
add_subdirectory()
```

---

执行：

```bash
cmake ..
```

CMake会：

进入：

```
motor
```

执行：

```
motor/CMakeLists.txt
```

得到：

```text
motor target
```

然后：

进入：

```
sensor
```

得到：

```text
sensor target
```

---

# 16.7 主程序

app/main.cpp

```cpp
#include "motor.hpp"
#include "sensor.hpp"


int main()
{

    Motor motor;

    motor.move();


    Sensor sensor;


    int value = sensor.read();


    return 0;
}
```

---

# 16.8 app/CMakeLists

创建：

```
app/CMakeLists.txt
```

内容：

```cmake
add_executable(
    robot_app
    main.cpp
)


target_link_libraries(
    robot_app
    PRIVATE
    motor
    sensor
)
```

---

这里：

```cmake
target_link_libraries()
```

连接：

```text
robot_app

↓

motor

↓

sensor

```

---

# 16.9 完整项目关系

现在：

```text
RobotProject


          robot_app

              |
        ----------------

        |              |

      motor          sensor

        |              |

    libmotor.a    libsensor.a

```

---

# 16.10 编译

创建build：

```bash
mkdir build

cd build
```

配置：

```bash
cmake ..
```

输出：

类似：

```text
-- Configuring done
-- Generating done
```

以上是Cmake配置，我使用的是 `cmake -S . -B build`

---

编译：

```bash
cmake --build .
```

生成：

```text
build

├── app
│   └── robot_app
│
├── motor
│   └── libmotor.a
│
└── sensor
    └── libsensor.a

```

以上是Cmake构建，我使用的是 `cmake --build build`

---

运行：

```bash
#这个命令执行的前提是在build目录内
./app/robot_app
#这里我的命令应该是
╭─ ~/ly_vscode/HelloCMake/16_1 main !1 ?4
╰─❯ ./build/app/robot_app
motor moving
```

输出：

```
motor moving
```

## 附:install

target在哪里定义，通常install就跟在哪里。 ~~谁创建 target，谁负责定义这个 target 的 install 规则~~ 根目录负责“项目管理”，子目录负责“自己的target”。

修改app/CMakeLists.txt，添加：  

```cmake
install(
        TARGETS robot_app
        DESTINATION bin
)
```

```bash
╭─ ~/ly_vscode/HelloCMake/16_1 main !1 ?4
╰─❯ cmake -B build -S .
-- Configuring done (0.0s)
-- Generating done (0.0s)
-- Build files have been written to: /home/ly/ly_vscode/HelloCMake/16_1/build

╭─ ~/ly_vscode/HelloCMake/16_1 main !1 ?4
╰─❯ cmake --build build
[ 33%] Built target motor
[ 66%] Built target sensor
[100%] Built target robot_app

╭─ ~/ly_vscode/HelloCMake/16_1 main !1 ?4
╰─❯ cmake --install build
-- Install configuration: ""
-- Installing: /usr/local/bin/robot_app
CMake Error at build/app/cmake_install.cmake:52 (file):
  file INSTALL cannot copy file
  "/home/ly/ly_vscode/HelloCMake/16_1/build/app/robot_app" to
  "/usr/local/bin/robot_app": Permission denied.
Call Stack (most recent call first):
  build/cmake_install.cmake:57 (include)



╭─ ~/ly_vscode/HelloCMake/16_1 main !1 ?4
╰─❯ sudo cmake --install build
[sudo] password for ly:
-- Install configuration: ""
-- Installing: /usr/local/bin/robot_app

╭─ ~/ly_vscode/HelloCMake/16_1 main !1 ?4
╰─❯ robot_app
motor moving
```

---

# 16.11 这个项目覆盖了哪些知识？

| 知识                         | 位置           |
| -------------------------- | ------------ |
| project                    | 根CMake       |
| add_subdirectory           | 管理模块         |
| add_library                | motor/sensor |
| STATIC库                    | motor        |
| target_include_directories | 头文件          |
| PUBLIC                     | 接口传播         |
| target_link_libraries      | 依赖关系         |
| target                     | 核心思想         |

---

# 16.12 如果加入OpenCV？

例如：

sensor使用OpenCV：

```cpp
#include <opencv2/opencv.hpp>
```

那么：

sensor/CMakeLists：

增加：

```cmake
find_package(OpenCV REQUIRED)


target_link_libraries(
    sensor
    PUBLIC
    ${OpenCV_LIBS}
)
```

关系：

```text
robot_app

↓

sensor

↓

OpenCV
```

由于：

```cmake
PUBLIC
```

所以：

robot_app自动继承OpenCV。

~~由于robot_app这个target目前没有直接使用OpenCV（main.cpp没用到），所以也可以设置为PRIVATE~~  

---

# 16.13 如果加入ROS2？

ROS2节点：

类似：

```text
robot_node

↓

sensor

↓

OpenCV

↓

ROS2
```

CMake：

```cmake
find_package(rclcpp REQUIRED)


target_link_libraries(
    robot_node
    PRIVATE
    sensor
)
```

ROS2中大量使用这种结构。

***以上只是一个说明，该示例并没有robot_node，代码不能直接使用***

---

# 16.14 本章总结

一个真实C++项目：

不是：

```text
main.cpp
CMakeLists.txt
```

而是：

```text
项目

├── app
│
├── 各功能模块
│
├── 第三方库
│
└── 顶层CMake管理
```

核心思想：

> 每个模块都是一个target，通过target之间的依赖关系组织整个工程。

到这里，前面规划的 **第1章～第16章 CMake基础路线全部完成**。

后续如果继续深入，可以学习：

1. **现代CMake高级用法**

   * generator expressions
   * alias target
   * interface library高级用法

2. **工程化**

   * CMake + Git
   * CMake + GoogleTest
   * CPack打包

3. **机器人方向**

   * ROS2 package.xml + CMakeLists.txt
   * ament_cmake
   * colcon build

结合你的目标（C++ + ROS2 + OpenCV），下一步最有价值的是：
**ROS2中的CMake结构解析**。你会发现ROS2的CMakeLists基本就是前面16章知识的综合应用。
