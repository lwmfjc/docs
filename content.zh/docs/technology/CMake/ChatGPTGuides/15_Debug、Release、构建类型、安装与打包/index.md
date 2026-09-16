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

# 15.7 `install()` —— 安装项目

前面我们一直关注：

```text
源码
 ↓
CMake
 ↓
build
 ↓
可执行文件/库
```

例如：

项目：

```text
Robot

├── CMakeLists.txt
├── src
│   └── main.cpp
├── include
│   └── motor.hpp
└── build
```

CMake构建：

```bash
cmake -S . -B build
cmake --build build
```

生成：

```text
build/

└── robot
```

现在问题来了：

如果别人使用你的程序：

他不知道：

* `robot` 应该放哪里？
* 库应该放哪里？
* 头文件应该放哪里？

Linux有一个约定：

```text
/usr/local
```

下面存放用户安装的软件。

例如：

```text
/usr/local

├── bin
│   └── robot
│
├── lib
│   └── libmotor.so
│
└── include
    └── motor.hpp
```

所以需要告诉 CMake：

> 编译完成后，把哪些东西复制到哪里。

这就是：

```cmake
install()
```

---

## 15.7.1 第一个 install 示例

项目：

```text
Robot

├── CMakeLists.txt
└── main.cpp
```

main.cpp：

```cpp
#include <iostream>


int main()
{
    std::cout
        << "robot start\n";

    return 0;
}
```

---

CMakeLists.txt：

```cmake
cmake_minimum_required(VERSION 3.20)


project(Robot)


add_executable(
    robot
    main.cpp
)

#调用 install() 命令，把名为 robot 的 target 纳入安装规则。
install(      #→ 命令名
TARGETS robot  #TARGETS→ install 的一个选项/关键字，robot→ 要安装的 target 名称
#DESTINATION bin #这里省略了这个，如果没有指定 DESTINATION，CMake 会根据平台和安装类型使用默认的 GNUInstallDirs 相关目录(这里默认也是bin)
)
```

---

这里：

```cmake
install(
    TARGETS
    robot
)
```

意思：

安装这个 target：

```text
robot
```

---

但是：

它安装到哪里？

如果没有指定：

使用：

```cmake
CMAKE_INSTALL_PREFIX
```

***配置***  

```bash
cmake \
-S . \
-B build \
```

---

## 15.7.2 `CMAKE_INSTALL_PREFIX`

这是 CMake 的安装根目录。

默认：

Linux：

```text
/usr/local
```

所以：

```cmake
install(
    TARGETS
    robot
)
```

实际类似：

```text
/usr/local/bin/robot
```

---

查看当前配置： ~~是用来查看 CMake 已经配置好的项目变量/缓存选项的。~~  

> 把 build 目录里的 CMake Cache 变量列出来，并包括高级变量，同时显示它们的帮助说明。

- -L：列出 CMake 的 Cache 变量
- -A：列出 advanced cache entries（高级缓存变量）
- -H：显示变量的 help/说明信息

```bash
╭─ ~/ly_vscode/HelloCMake/15_2 main ?1                                                     
╰─❯ cmake -LAH build | grep INSTALL_PREFIX
CMAKE_INSTALL_PREFIX:PATH=/usr/local
```

可以看到：

```text
CMAKE_INSTALL_PREFIX=/usr/local
```

---

### 修改安装位置

例如：

安装到：

```text
/opt/robot
```

配置：

```bash
cmake \
-S . \
-B build \
-DCMAKE_INSTALL_PREFIX=/opt/robot
```

然后：

```bash
cmake --build build
```

安装：

```bash
#build之后才能install
#install需要管理员权限
╭─ ~/ly_vscode/HelloCMake/15_2 main ?1
╰─❯ sudo cmake --install build
[sudo] password for ly:
-- Install configuration: ""
-- Installing: /usr/local/bin/robot
```

结果：

```text
/opt/robot/bin/robot
```

**修改安装位置 的话，得另外把位置路径加入path，才能*直接*在bash中 robot运行**

```bash
#因为 /usr/local/binabc 没有加入 PATH
╭─ ~/ly_vscode/HelloCMake/15_2 main ?1
╰─❯ robot
zsh: command not found: robot
#冒号 : 是 PATH 中用来分隔多个目录的分隔符
╭─ ~/ly_vscode/HelloCMake/15_2 main ?1
╰─❯ export PATH="/opt/robot/bin:$PATH"

╭─ ~/ly_vscode/HelloCMake/15_2 main ?1
╰─❯ robot
robot start
```

### 附：如何删除

如果使用普通的安装方式，CMake 通常会在 build 目录生成：

```
build/install_manifest.txt
```

里面记录安装了哪些文件，例如：

```
/usr/local/bin/robot
/usr/local/lib/libmotor.so
```

所以可以根据这个清单删除已安装文件。

例如：

```
sudo xargs rm < build/install_manifest.txt
```

------

```
sudo     xargs rm     < build/install_manifest.txt
 │          │                  │
 │          │                  └─ 把文件内容作为输入
 │          └─ 根据输入执行 rm
 └─ 以 root 权限执行
```

如果去除了xargs

```
sudo rm < build/install_manifest.txt
```

这里的 < 不会把文件内容变成 rm 的命令行参数。

它只是：

```
把 build/install_manifest.txt 打开，并把它连接到 rm 的标准输入（stdin）。
```

***而 rm 要删除什么，要求的是命令行参数***  

------

这样就相当于：

```
install
   ↓
cmake --install build
   ↓
安装文件
   ↓
install_manifest.txt 记录安装了什么
   ↓
根据清单删除
   ↓
实现卸载
```

---

## 15.7.3 安装可执行文件

更推荐明确写：

```cmake
install(
    TARGETS
    robot

    DESTINATION
    bin
)
```

完整：

```cmake
cmake_minimum_required(VERSION 3.20)


project(Robot)


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

---

执行：

```bash
cmake -S . -B build
```

生成安装规则。

编译：

```bash
cmake --build build
```

安装：

```bash
cmake --install build
```

---

如果：

```
╭─ ~/ly_vscode/HelloCMake/15_2 main ?1                                         
╰─❯ cmake -LAH build | grep INSTAL
CMAKE_INSTALL_PREFIX:PATH=/usr/local
CMAKE_SKIP_INSTALL_RPATH:BOOL=NO
```

结果：

```text
/usr/local

└── bin

    └── robot
```

------
### 修改DESTINATION为binabc   

```cmake
install(
    TARGETS
    robot
    DESTINATION
    bin
)
```

```bash

╭─ ~/ly_vscode/HelloCMake/15_2 main ?1
╰─❯ sudo cmake --install build
-- Install configuration: ""
-- Installing: /usr/local/binabc/robot

#因为 /usr/local/binabc 没有加入 PATH
╭─ ~/ly_vscode/HelloCMake/15_2 main ?1
╰─❯ robot
zsh: command not found: robot
#冒号 : 是 PATH 中用来分隔多个目录的分隔符
╭─ ~/ly_vscode/HelloCMake/15_2 main ?1
╰─❯ export PATH="/usr/local/binabc:$PATH"

╭─ ~/ly_vscode/HelloCMake/15_2 main ?1
╰─❯ robot
robot start
```

---

## 15.7.4 DESTINATION和CMAKE_INSTALL_PREFIX区别

> CMAKE_INSTALL_PREFIX 是“安装根目录”，默认通常是 /usr/local。
> DESTINATION 是“相对于安装根目录的目标目录”，没有统一的默认值，取决于安装的 target 类型/写法。  

上面其实没有介绍全面，install可以是可执行文件，也可以是头文件，还可以是库。这些都是CMAKE_INSTALL_PREFIX指定目录下的自带子项 ~~子文件~~ 

```shell

install(
    TARGETS robot
    DESTINATION bin
)

install(
    FILES robot.h
    DESTINATION include
)

install(
    TARGETS motor
    DESTINATION lib
)
```

***下面有更常见更完整的写法***

## 15.7.5 安装库

实际项目经常不是只有一个 exe。

例如：

机器人项目：

```text
robot_app

依赖：

motor库
sensor库 #这里不涉及
```

结构：

```text
Robot

├── CMakeLists.txt
│
├── motor
│   ├── motor.cpp
│   └── motor.hpp
│
└── main.cpp
```

---

motor.cpp：

```cpp
//编译器会首先在当前源文件所在目录查找，找不到的话才需要
//到编译器的头文件搜索路径中去找，所以下面CMakeLists不需要：
/*
target_include_directories
(
	motor
	PUBLIC
	motor
)
*/

#include "motor.hpp"
void Motor::run()
{

}
```

---

motor.hpp：

```cpp
#pragma once


class Motor
{
public:

    void run();

};
```

------

main.cpp

```cpp
include <iostream>

int main()
{
        std::cout << "hello" << std::endl;
        return 0;
}
```

---

CMakeLists.txt：

```cmake
cmake_minimum_required(VERSION 3.20)


project(Robot)


add_library(
    motor
    SHARED
    motor/motor.cpp
)


add_executable(
    robot
    main.cpp
)


target_link_libraries(
    robot
    PRIVATE
    motor
)


install(
    TARGETS robot motor
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
)
```

---

这里：

```cmake
RUNTIME DESTINATION bin
```

安装：

可执行文件。

Linux：

```text
robot
```

→

```text
bin/
```

---

```cmake
LIBRARY DESTINATION lib
```

安装：

动态库：

```text
libmotor.so
```

→

```text
lib/
```

---

结果：

```bash
╭─ ~/ly_vscode/HelloCMake/15_3 main ?2
╰─❯ sudo cmake --install build
[sudo] password for ly: 
-- Install configuration: "" #当前没有指定 Debug / Release 等配置。
-- Installing: /usr/local/bin/robot
#→ 将 /usr/local/bin/robot 的非工具链部分运行时库搜索路径设置为空。
#翻译上面那句话，即：CMake 正在处理 robot 运行时寻找动态库（.so）的路径，这里最终没有额外设置运行时搜索路径。
-- Set non-toolchain portion of runtime path of "/usr/local/bin/robot" to ""
-- Installing: /usr/local/lib/libmotor.so
```

解释一下，也就是说也可以额外设置运行时搜索（库文件）的搜索路径，如：  

```cmake
set_target_properties(robot PROPERTIES
    INSTALL_RPATH "/opt/mylibs"
)
```

```text
/usr/local

├── bin
│   └── robot
│
└── lib
    └── libmotor.so
```

> 对于库的编译，通常需要相关头文件；对于已经编译好的可执行文件，运行时不需要头文件。
> 如果其他人要使用这个库并编译自己的程序，就需要这个库提供的公开头文件，所以安装库时通常也需要安装头文件，所以才有下面的**安装头文件**。

---

## 15.7.6 安装头文件

如果别人想使用你的库：

例如：

```cpp
#include <motor.hpp>
```

那么：

头文件也需要安装。

---

目录：

```text
Robot

├── include
│   └── motor.hpp
│
├── motor.cpp
└── CMakeLists.txt
```

---

CMake：

增加：

```cmake
install(
    DIRECTORY
    include/

    DESTINATION
    include
)
```

完整：

```cmake
cmake_minimum_required(VERSION 3.20)


project(Robot)


add_library(
    motor
    SHARED
    motor.cpp
)


target_include_directories(
    motor
    PUBLIC
    include
)


install(
    TARGETS
    motor

    LIBRARY DESTINATION lib
)


install(
    DIRECTORY
    include/

    DESTINATION
    include
)
```

---

安装后：

```text
/usr/local

├── lib
│   └── libmotor.so
│
└── include
    └── motor.hpp
```


### 使用

```shell
#include <motor.hpp>
```

不需要写`/usr/local/include/motor.hpp`。  

因为 `/usr/local/include` 通常已经是 GCC 的默认头文件搜索路径。  
至于链接：  

`target_link_libraries(app PRIVATE motor)`

因为 libmotor.so 在 /usr/local/lib，CMake/链接器通常能够找到它。 ~~因为 /usr/local/lib 通常也是系统默认库搜索目录~~ 

### .so不在默认路径

#### 1. 编译/链接阶段：告诉链接器去哪里找

假设：

```text
/opt/motor/
├── include/
│   └── motor.hpp
└── lib/
    └── libmotor.so
```

CMake：

```cmake
add_executable(app main.cpp)

target_include_directories(app PRIVATE /opt/motor/include)

target_link_directories(app PRIVATE /opt/motor/lib)

#这里motor 只是库名称
target_link_libraries(app PRIVATE motor)
```

这里：

```cmake
target_link_directories(app PRIVATE /opt/motor/lib)
```

相当于告诉链接器：

> `libmotor.so` 去 `/opt/motor/lib` 里面找。

目录：

```
/opt/motor/
├── include/
│   └── motor.hpp
└── lib/
    └── libmotor.so
```

然后：

```
target_link_directories(app PRIVATE /opt/motor/lib)
target_link_libraries(app PRIVATE motor)
```

CMake 会把 motor 当作一个普通链接项，最终交给链接器，效果类似：

```
g++ ... -L/opt/motor/lib -lmotor
```

而：

```
motor
  ↓
-lmotor
  ↓
libmotor.so
```

所以不需要事先 `add_library(motor ...)`。

但是要注意一个重要区别

如果你写：

`target_link_libraries(app PRIVATE motor)`

CMake 会尝试理解：

有没有叫 motor 的 CMake target？

如果没有，就把它当成普通库名/链接器参数处理。

```
add_library(motor ...)
        ↓
创建 CMake target：motor


target_link_libraries(app PRIVATE motor)
        ↓
优先使用这个 target
        ↓
如果没有这样的 target
        ↓
可以作为普通链接项处理
```

---

#### 2. 但是运行时又是另一回事

即使编译成功：

```bash
cmake --build build
```

运行：

```bash
./build/app
```

仍然可能出现：

```text
error while loading shared libraries: libmotor.so:
cannot open shared object file: No such file or directory
```

因为：

```text
编译时找 .so
        ↓
链接器

运行时找 .so
        ↓
动态链接器
```

是**两个不同的搜索过程**。

---

#### 3. 最简单的运行方式

临时指定：

```bash
LD_LIBRARY_PATH=/opt/motor/lib ./build/app
```

意思就是：

> 运行 `app` 时，额外去 `/opt/motor/lib` 找 `.so`。

也可以：

```bash
export LD_LIBRARY_PATH=/opt/motor/lib:$LD_LIBRARY_PATH
./build/app
```

---

#### 4. 更推荐 CMake 给程序写入 RPATH

例如：

```cmake
set_target_properties(app PROPERTIES
    BUILD_RPATH "/opt/motor/lib"
)
```

这样构建出来的 `app` 会记录：

```text
运行 app
  ↓
去 /opt/motor/lib
  ↓
找 libmotor.so
```

就不需要每次：

```bash
LD_LIBRARY_PATH=...
```

---

所以完整理解就是：

```text
/opt/motor/lib/libmotor.so
          ↓
┌─────────────────────────┐
│ 编译/链接阶段             │
│ target_link_directories  │
└─────────────────────────┘
          ↓
       生成 app
          ↓
┌─────────────────────────┐
│ 运行阶段                 │
│ LD_LIBRARY_PATH          │
│ 或 RPATH                 │
└─────────────────────────┘
          ↓
     找到 libmotor.so
```

**`target_link_directories()` 解决的是“编译时在哪里找”，并不自动等于“运行时在哪里找”。**

---

## 15.7.7 完整真实项目安装结构

一个小型机器人库：

源码：

```text
Robot

├── CMakeLists.txt
│
├── include
│   └── motor.hpp
│
├── src
│   └── motor.cpp
│
└── app
    └── main.cpp
```

安装后：

```text
/usr/local

├── bin
│   └── robot
│
├── lib
│   └── libmotor.so
│
└── include
    └── motor.hpp
```

这就是 Linux 下很多 C++ 库的标准布局。

例如：

安装 OpenCV：

```text
/usr/include/opencv4
/usr/lib/x86_64-linux-gnu
```

安装 ROS2：

```text
/opt/ros/jazzy
```

本质上也是类似思想。

---

## 本节核心总结

### 安装可执行文件：

```cmake
install(
    TARGETS robot
    DESTINATION bin
)
```

结果：

```text
/usr/local/bin/robot
```

---

### 安装动态库：

```cmake
install(
    TARGETS motor
    LIBRARY DESTINATION lib
)
```

结果：

```text
/usr/local/lib/libmotor.so
```

---

### 安装头文件：

```cmake
install(
    DIRECTORY include/
    DESTINATION include
)
```

结果：

```text
/usr/local/include/*.hpp
```

---

### 安装流程：

```text
CMake配置

cmake -S . -B build


↓

编译

cmake --build build


↓

安装

cmake --install build
```

---

这部分和你后面学习 ROS2 会直接关联，因为 ROS2 的：

```bash
colcon build
```

生成的：

```text
install/
```

目录，就是大量 CMake `install()` 规则组合出来的结果。你之前执行：

```bash
source install/setup.bash
```

本质上就是在使用安装后的环境。

# 15.8 为什么ROS2大量用install？

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

# 15.9 本章总结

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
