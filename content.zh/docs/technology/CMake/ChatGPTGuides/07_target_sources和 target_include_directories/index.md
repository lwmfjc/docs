---
title: 07_target_sources和 target_include_directories
description: 07_target_sources和 target_include_directories
categories:
  - 学习
tags:
  - 单片机
  - STM32
  - 江科大
date: 2026-09-10T18:04:25+08:00
lastmod: 2026-09-10T18:04:25+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
***第7章：target_sources 和 target_include_directories***  

这一章非常重要，因为它解决两个实际工程问题：

1. **源码文件越来越多怎么办？**
2. **头文件在哪里，CMake怎么知道？**

这两个问题在 STM32、ROS2、OpenCV 项目里天天出现。

---

# 7.1 为什么需要 target_sources？

前面我们写：

```cmake
add_executable(
    robot

    main.cpp
    robot.cpp
)
```

这种写法没有问题。

但是项目大一点：

```
RobotProject

├── CMakeLists.txt
│
├── src
│   ├── main.cpp
│   ├── robot.cpp
│   ├── motor.cpp
│   ├── sensor.cpp
│   └── camera.cpp
│
└── include
    ├── robot.h
    ├── motor.h
    └── sensor.h
```

你可能写：

```cmake
add_executable(
    robot

    src/main.cpp
    src/robot.cpp
    src/motor.cpp
    src/sensor.cpp
    src/camera.cpp
)
```

可以。

但是现代 CMake 更推荐：

先创建 target：

```cmake
add_executable(robot)
```

然后：

```cmake
target_sources(
    robot

    PRIVATE

    src/main.cpp
    src/robot.cpp
    src/motor.cpp
    src/sensor.cpp
)
```

---

# 7.2 add_executable 和 target_sources区别

其实：

```cmake
add_executable(
    robot

    main.cpp
)
```

等价于：

```cmake
add_executable(robot)


target_sources(
    robot

    PRIVATE

    main.cpp
)
```

也就是说：

第一种：

> 创建target，同时添加源码

第二种：

> **创建target，然后后面慢慢添加源码**

---

为什么第二种更常见？

因为大型项目经常分文件。

例如：

根目录：

```
CMakeLists.txt
```

里面：

```cmake
add_executable(robot)
```

然后：

src/CMakeLists.txt：

```cmake
target_sources(
    robot

    PRIVATE

    main.cpp
    robot.cpp
)
```

drivers/CMakeLists.txt：

```cmake
target_sources(
    robot

    PRIVATE

    motor.cpp
)
```

最后：

所有源码都会进入：

```
robot target
```

---

# 7.3 PRIVATE是什么意思？

这里第一次遇到：

```cmake
target_sources(
    robot

    PRIVATE

    main.cpp
)
```

先不要深入。

简单理解：

```text
PRIVATE = 只给自己用
```

例如：

```
robot

拥有：

main.cpp
motor.cpp
```

这些只是 robot 自己的源码。

所以：

```cmake
PRIVATE
```

---

后面讲：

```text
PUBLIC
INTERFACE
```

时会详细解释。

这三个是 CMake 最重要的关键字之一。

---

# 7.4 头文件问题

现在看：

```
project

├── src
│   └── main.cpp
│
└── include
    └── motor.h
```

main.cpp：

```cpp
#include "motor.h"

int main()
{

}
```

编译：

```bash
g++ src/main.cpp
```

可能报错：

```
fatal error:
motor.h: No such file or directory
```

为什么？

因为编译器默认只找：

当前目录：

```
src/
```

但是：

你的文件：

```
include/motor.h
```

不在那里。

---

所以需要告诉编译器：

> 头文件去哪里找？

这就是：
# 7.5 target_include_directories

写：

```cmake
target_include_directories(
    robot

    PRIVATE

    include
)
```

意思：

给 robot 添加头文件搜索路径：

```
include/
```

于是：

编译器知道：

```
#include "motor.h"

去：

include/motor.h

找
```

---

完整：

目录：

```
Robot

├── CMakeLists.txt
│
├── src
│   └── main.cpp
│
└── include
    └── motor.h
```

CMake：

```cmake
cmake_minimum_required(VERSION 3.20)

project(Robot)


add_executable(robot)


target_sources(
    robot

    PRIVATE

    src/main.cpp
)


#只有 target robot 自己在编译时，会把 include 加入头文件搜索路径。
#如果还有另一个 target2，那么它是不会从include文件夹找他要的头文件的
target_include_directories(
    robot

    PRIVATE

    include
)
```

## 指定的目录是否target之间可见

`target_include_directories()` 的作用范围取决于你写的 **target 名字** 和 **访问权限关键字（PRIVATE / PUBLIC / INTERFACE）**。

你的例子：

```cmake
target_include_directories(
    robot
    PRIVATE
    include
)
```

意思是：

> **只有 target `robot` 自己在编译时，会把 `include` 加入头文件搜索路径。**

不会影响其他 target。

---

举个例子：

目录：

```
project
├── CMakeLists.txt
├── include
│   └── robot.h
├── robot
│   └── robot.cpp
└── robot2
    └── robot2.cpp
```

CMake：

```cmake
add_executable(robot robot/robot.cpp)

target_include_directories(
    robot
    PRIVATE
    include
)


add_executable(robot2 robot2/robot2.cpp)
```

此时：

**robot.cpp**

```cpp
#include "robot.h"
```

✅ 可以找到：

```
project/include/robot.h
```

因为：

```
robot
 └── include路径
```

---

**robot2.cpp**  

```cpp
#include "robot.h"
```

❌ 找不到。

因为：

```
robot2
 └── 没有 include 目录
```

`PRIVATE` 不会传播。

---

### 那如果换成 PUBLIC 呢？

```cmake
target_include_directories(
    robot
    PUBLIC
    include
)
```

含义：  
1. robot 自己使用 include
2. 所有**链接 robot 的 target 也继承** include

```

例如：

```cmake
add_library(robot robot.cpp)

target_include_directories(
    robot
    PUBLIC
    include
)


add_executable(robot2 main.cpp)

target_link_libraries(
    robot2
    robot
)
```

关系：

```
robot2
   |
   | link
   ↓
 robot
   |
   ↓
include
```

那么：

```cpp
#include "robot.h"
```

在 `robot2` 里面也能用。

---

### INTERFACE 呢？

```cmake
target_include_directories(
    robot
    INTERFACE
    include
)
```

表示：

> **robot 自己不用，但是使用 robot 的目标需要。**

典型场景：

纯头文件库：

```
robot/
 └── robot.hpp
```

没有 cpp：

```cmake
add_library(robot INTERFACE)

target_include_directories(
    robot
    INTERFACE
    include
)
```

然后：

```cmake
target_link_libraries(
    robot2
    robot
)
```

robot2 获得头文件路径。

---

### 总结表

| 关键字       | robot自己 | 链接robot的其他target |
| --------- | ------- | ---------------- |
| PRIVATE   | ✅ 有     | ❌ 无              |
| PUBLIC    | ✅ 有     | ✅ 有              |
| INTERFACE | ❌ 无     | ✅ 有              |

---

所以你的问题：

> 如果还有另一个 target-robot2 呢？

答案：

如果：

```cmake
target_include_directories(robot PRIVATE include)
```

那么：

```
robot
  ✅ 可以include include/

robot2
  ❌ 不可以
```

除非你另外写：

```cmake
target_include_directories(robot2 PRIVATE include)
```

或者：

```cmake
target_link_libraries(robot2 robot)
```

并且 `robot` 使用：

```cmake
PUBLIC
```

暴露头文件路径。

---

实际工程里（尤其 STM32/C++ 项目）通常推荐 ~~通常用PUBLIC~~ ：

```cmake
add_library(robot ...)
target_include_directories(robot PUBLIC include)
```

因为别人**链接**这个库时，不需要再手动知道它的头文件在哪里。CMake 会自动传递依赖。


# 7.6 include目录为什么不用写文件？

注意：

这里：

```cmake
target_include_directories(
    robot

    PRIVATE

    include
)
```

写的是：

```
include
```

不是：

```
include/motor.h
```

因为：

include目录的作用是：

告诉编译器：

```
以后遇到：

#include "xxx.h"


去这里搜索
```

---

比如：

include：

```
include

├── motor.h
├── sensor.h
└── camera.h
```

代码：

```cpp
#include "motor.h"
#include "sensor.h"
#include "camera.h"
```

都可以找到。

---

# 7.7 和 Java 对比

这个你应该容易理解。

Java：

```java
import com.example.User;
```

JVM需要知道：

```
classpath在哪里
```

例如：

```
lib/user.jar
```

C++：

```cpp
#include "motor.h"
```

编译器需要知道：

```
include路径在哪里
```

例如：

```
include/
```

对应：

| Java      | C++       |
| --------- | --------- |
| classpath | include目录 |
| jar       | 库         |
| import    | include   |

---

# 7.8 回到你的 STM32 CMake

你之前贴过：

```cmake
target_sources(
    ${PROJECT_NAME}

    PRIVATE

    Src/main.c

    Core/system_stm32f10x.c

    Startup/startup_stm32f10x_md.s
)
```

现在你应该能理解：

它不是：

"扫描Src文件夹"

而是：

明确告诉：

```
STM32Test这个target

需要这些源码
```

---

类似：

```cmake
target_include_directories(
    ${PROJECT_NAME}

    PRIVATE

    Core
    Drivers
)
```

意思：

告诉编译器：

以后：

```c
#include "stm32f10x.h"
```

去：

```
Core/
Drivers/
```

找。

---

# 7.9 一个完整现代CMake例子

目录：

```
Robot

├── CMakeLists.txt

├── src
│   ├── main.cpp
│   └── motor.cpp

└── include
    └── motor.h
```

CMake：

```cmake
cmake_minimum_required(VERSION 3.20)


project(Robot)


add_executable(robot)


target_sources(
    robot

    PRIVATE

    src/main.cpp
    src/motor.cpp
)


target_include_directories(
    robot

    PRIVATE

    include
)
```

最终关系：

```
              robot target

                   |
        ----------------------
        |                    |
     源文件                头文件路径

 main.cpp              include/
 motor.cpp                  |
                            |
                        motor.h
```

---

# 本章总结

你需要记住：

## 添加源码

旧：

```cmake
add_executable(
    robot
    main.cpp
)
```

现代：

```cmake
add_executable(robot)

target_sources(
    robot
    PRIVATE
    main.cpp
)
```

---

## 添加头文件搜索路径

```cmake
target_include_directories(
    robot

    PRIVATE

    include
)
```

作用：

让：

```cpp
#include "xxx.h"
```

能够找到：

```
include/xxx.h
```

---

现在你的知识体系：

```
CMake

├── target
│
├── target_sources
│
├── target_include_directories
│
└── target_link_libraries
```

已经开始接近真实工程。

# 补充：至今为止的一些命令顺序

- 这些统称为`CMake command（命令）`  
- 很多 CMake 命令的第一个参数通常是**操作对象（target）**，后面的参数**描述属性**。
- 括号()里面的叫**参数**，参数之间以**空白符** ~~换行、空格、Tab效果一样~~ 或者分号 ~~即;但是可读性差~~ 分割，**括号**表示**命令边界**  
- 

> CMakeLists.txt 不是像 C/C++ 那样严格按声明顺序全部决定，但它是“从上到下执行”的；凡是 target_xxx() 命令，都要求对应 target 已经存在。cmake_minimum_required() 和 project() 基本固定放前面。

类似：  

```
cmake_minimum_required()
        ↓
project()
        ↓
add_library()
add_executable()
        ↓
target_sources()
target_include_directories()
target_link_libraries()
```

下一章会讲：

# 第8章：target_link_libraries 深入 + 静态库/动态库

会解释：

* `.a` 和 `.so`到底怎么链接
* 为什么库也可以成为target
* 为什么ROS2大量使用 `target_link_libraries`
* 为什么现代CMake不推荐直接写库路径

这章会把你之前关于 OpenCV target 的疑问彻底串起来。
