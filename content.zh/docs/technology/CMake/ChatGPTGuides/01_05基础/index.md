---
title: 01_05基础
description: 01_05基础
categories:
  - 学习
tags:
  - CMake
  - ChatGPTGuides
date: 2026-09-10T09:53:22+08:00
lastmod: 2026-09-10T09:53:22+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
~~这是一篇由ChatGPT生成的CMake教程~~  

可以。我会按照**完全零基础 → 能看懂工业项目 CMakeLists.txt → 能自己写 CMake 工程**的路线讲。

你目前的背景（Java Web + 最近 STM32/C++）其实比较适合学 CMake，因为 CMake 本质上不是编程语言，而是**管理 C/C++项目构建的工具**。你之前接触的 `Makefile`、`gcc-arm-none-eabi`、STM32 CMake 工程，都会涉及它。

整个学习路线：

```
第1章  编译、链接、构建到底是什么（理解为什么需要CMake）
第2章  Make是什么
第3章  CMake是什么，它和Make关系
第4章  第一个CMake项目
第5章  CMake核心语法
第6章  管理多个源文件
第7章  静态库、动态库
第8章  include目录管理
第9章  target思想（最重要）
第10章 CMake变量
第11章 CMake条件判断和循环
第12章 工程目录组织
第13章 Debug/Release构建
第14章 第三方库管理
第15章 install/package
第16章 STM32项目中的CMake
```

今天先从基础开始。

```shell
#这是我在debian13用的工具链版本
ly@dba13:~$ gcc --version
gcc (Debian 14.2.0-19) 14.2.0
Copyright (C) 2024 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

ly@dba13:~$ make --version
GNU Make 4.4.1
Built for x86_64-pc-linux-gnu
Copyright (C) 1988-2023 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
ly@dba13:~$ cmake --version
cmake version 3.31.6

CMake suite maintained and supported by Kitware (kitware.com/cmake).

```

---

# 第1章：为什么需要CMake？

## 1.1 一个C++程序如何产生？

比如：

main.cpp

```cpp
#include <iostream>

int main()
{
    std::cout<<"hello"<<std::endl;
    return 0;
}
```

你不能直接运行：

```
main.cpp
```

计算机不认识 C++。

需要经过：

```
.cpp
 |
 | 编译
 ↓
.o目标文件
 |
 | 链接
 ↓
可执行文件
 |
 ↓
运行
```

例如：

```
main.cpp
   |
   gcc
   |
main.o
   |
   linker
   |
hello.exe
```

---

## 1.2 手动编译

假设：

```
project

├── main.cpp
├── math.cpp
└── math.h
```

你可以：

```bash
g++ main.cpp math.cpp -o app
```

生成：

```
app.exe/app
```

运行：

Linux:

```bash
./app
```

Windows:

```
app.exe
```

小项目没问题。

---

# 但是大型项目呢？

比如：

Linux内核：

```
几十万个.c文件
```

ROS2：

```
几百个package

每个package:
    src
    include
    msg
    srv
    test
```

STM32工程：

```
Core
Drivers
Middlewares
Startup
Libraries
Application
```

你不可能：

```bash
gcc a.c b.c c.c d.c .....
```

所以需要：

## 构建系统(build system)

负责：

* **哪些文件需要编译**
* **编译参数**
* **头文件路径**
* **库依赖**
* **生成什么文件**

常见：

```
Make
Ninja
CMake
Bazel
Meson
```

---

# 第2章：Make是什么？

Make是最早流行的构建工具。

它通过：

```
Makefile
```

描述：

"怎么编译这个项目"

例如：

目录：

```
hello

├── main.cpp
└── Makefile
```

Makefile:

```makefile
app:
	g++ main.cpp -o app
```

------

> 这里，g++前面一定要放一个tab键 ~~一定不能是空格~~

```shell
#这里设置制表符长度为4，默认的8太长了
vim ~/.vimrc
set tabstop=4       " 将 Tab 制表符在屏幕上的显示宽度设为 4 个字符
set shiftwidth=4    " 缩进操作（如 >> 或 <<）的移动宽度设为 4 个字符
set softtabstop=4   " 按 Backspace 退格键时，把 4 个字符当成一个 Tab 一起删除
" set expandtab     " 确保这行已被删除或注释掉，保持 Tab 为原生制表符

#退出之后重进即可
```
 ------

执行：

```bash
make
```

结果：

```
g++ main.cpp -o app
```

生成：

```
app
```

---

## 2.1 Make的核心思想

Make里面有：

目标(target)  

> 简介：CMake根据配置文件创建target。target不是文件，而是CMake内部描述“如何构建某个东西”的对象。它记录头文件路径、库文件、编译参数等信息。是CMake内部维护的一个构建对象。

例如：

```
app
```

依赖：

```
main.cpp
```

关系：

```
app
 |
依赖
 |
main.cpp
```

写成：

```makefile
app: main.cpp
	g++ main.cpp -o app
```

意思：

如果：

```
app不存在
```

或者：

```
main.cpp更新了
```

重新编译。

### make基本使用

```shell
#声明伪目标（Phony Targets）。告诉 make 工具：all 和 clean 不是文件名，只是两个命令标签/动作指令。
.PHONY: all clean

# 第一个目标：列出所有需要构建的程序/文件
all: app1 app2

# 规则 1：生成 app1
app1: main1.cpp
	g++ main1.cpp -o app1

# 规则 2：生成 app2
app2: main2.cpp
	g++ main2.cpp -o app2

clean:
	rm -f app1 app2


```

- 第一目标原则：当你只敲 make 不带参数时，make 默认只寻找并执行 Makefile 中的第一个规则。
- 依赖链触发：当第一个规则是 all: app1 app2 时，make 会发现 all 依赖于 app1 和 app2。为了完成 all，它会去依次检查并执行 app1 和 app2 对应的编译命令，从而实现了“一次性编译所有目标”的效果。
- .PHONY: all clean 作用：显式声明 all 及 clean 为伪目标，可以防止当前目录下如果刚好存在一个叫 all 或者 clean 的文件而导致 make 停止运行。 ~~make 会误以为目标已经完成，如下，会说明目标名和实际名字的作用~~ 


基本演示：  

```shell
ly@dba13:~/cmakeTest$ ls
app1  app2  main1.cpp  main2.cpp  Makefile
ly@dba13:~/cmakeTest$ make
make: Nothing to be done for 'all'.
ly@dba13:~/cmakeTest$ rm app1 app2
ly@dba13:~/cmakeTest$ ls
main1.cpp  main2.cpp  Makefile
ly@dba13:~/cmakeTest$ make
g++ main1.cpp -o app1
g++ main2.cpp -o app2
ly@dba13:~/cmakeTest$ ls
app1  app2  main1.cpp  main2.cpp  Makefile
ly@dba13:~/cmakeTest$ make
make: Nothing to be done for 'all'.
ly@dba13:~/cmakeTest$ make clean
rm -f app1 app2
ly@dba13:~/cmakeTest$ make
g++ main1.cpp -o app1
g++ main2.cpp -o app2

```

### 目标名和实际名字

“名字一样”指的是：**Makefile 中的目标名称（Target）与 `g++` 编译输出的二进制文件名保持完全一致。**

---

#### 一、 错误写法与正确写法的对比

##### 1. 名字不一样（错误/不推荐）

```make
app1: main.cpp
	g++ main.cpp -o app2

```

* **目标名**是 `app1`。
* **实际生成的文件**是 `app2`。
* **后果**：运行 `make` 后，磁盘上生成了 `app2`。但当再次运行 `make` 时，`make` 去检查磁盘，发现**根本没有 `app1` 这个文件**。`make` 会以为上次编译失败或文件丢失了，于是**每一次运行 `make` 都会强制重新编译一次**。

##### 2. 名字一样（正确标准写法）

```make
app2: main.cpp
	g++ main.cpp -o app2

```

* **目标名**是 `app2`。
* **实际生成的文件**也是 `app2`。
* **结果**：运行 `make` 后，磁盘上生成了 `app2`。当再次运行 `make` 时，`make` 会去检查 `app2` 文件是否存在、以及它的修改时间是否比 `main.cpp` 更新。如果是，`make` 就会提示：
> `make: 'app2' is up to date.`
> 并跳过编译，节省编译时间。

#### 二、 为什么一定要“名字一样”？

`make` 工具的核心设计哲学是：**基于文件修改时间（Timestamp）的增量编译**。

`make` 的工作流程如下：

1. **检查目标文件是否存在**：如果目标文件（如 `app2`）不存在，执行下方命令生成它。
2. **比较修改时间**：如果目标文件 `app2` 已经存在，`make` 会对比 `app2` 和依赖文件 `main.cpp` 的最后修改时间：
* 如果 `main.cpp` 的修改时间**晚于** `app2`（说明源码被改过），重新编译。
* 如果 `main.cpp` 的修改时间**早于** `app2`（说明源码没动过），直接跳过编译。

**如果你把目标名字写成 `app1`，而命令却生成 `app2`，`make` 的时间戳检查机制就彻底失效了**。因为 `make` 永远找不到 `app1`，导致它失去了自动判断“是否需要重新编译”的能力。

#### 三、 唯一的例外：伪目标（`.PHONY`）

如果你定义的目标**本来就不打算生成任何文件**（例如清理垃圾文件的规则），你才不需要让它对应实际文件名。这种目标被称为**伪目标**：

```make
.PHONY: clean

clean:
	rm -f app2

```

这里的 `clean` 只是一个命令代号，通过 `.PHONY: clean` 显式告诉 `make`：“`clean` 不是一个文件名，不需要去检查磁盘上有没有叫 `clean` 的文件，直接执行命令即可。”

## 2.2 Make的问题

大型项目：

Makefile会非常复杂。

例如：

Linux kernel：

几十万行Makefile。

所以后来出现：

**CMake**

# 第3章：CMake是什么？

一句话：

> CMake是生成构建文件的工具。

注意：

CMake自己不负责编译。

关系：

```
CMakeLists.txt

        |
        |
        ↓

生成

        |
        |

Makefile / Ninja文件

        |
        |
        ↓

gcc编译

        |
        |
        ↓

程序
```

完整流程：

```
你写

CMakeLists.txt


↓

cmake


↓

Makefile


↓

make


↓

gcc


↓

exe
```

---

所以：

CMake不是替代Make。

关系：

```
CMake
  |
  |生成Makefile
  ↓
Make
  |
  |调用
  ↓
gcc
```

---

# 第4章：第一个CMake项目

创建：

```
HelloCMake

├── CMakeLists.txt
└── main.cpp
```

main.cpp:

```cpp
#include <iostream>


int main()
{
    std::cout<<"Hello CMake"<<std::endl;

    return 0;
}
```

---

## CMakeLists.txt

创建：

```
CMakeLists.txt
```

内容：

```cmake
#对cmake的最低版本要求为3.20，低了会报错
cmake_minimum_required(VERSION 3.20)
#项目名叫Hello,执行后自动产生变量PROJECT_NAME,值为Hello
#注意，只有一个executable的时候，这里Hello和hello建议保持一致(不一致也没什么大问题)
project(Hello) 
#生成一个可执行程序，名字为hello，源码是main.cpp
add_executable(
	hello
	main.cpp
)

```

逐行解释。

---

## 1.要求最低CMake版本

```cmake
cmake_minimum_required(VERSION 3.20)
```

表示：

要求最低CMake版本。

比如：

你的CMake：

```
3.10
```

但是：

项目要求：

```
3.20
```

会报错。

类似：

Java:

```java
require java 17
```

---

## 2.定义项目名称

```cmake
project(Hello)
```

定义项目名称。

相当于：

```
项目叫 Hello
```

执行后：

CMake自动产生变量：

```
PROJECT_NAME
```

值：

```
Hello
```

---

## 3.生成一个可执行程序

```cmake
add_executable(
    hello
    main.cpp
)
```

这是最核心命令。

意思：

生成一个可执行程序：

名字：

```
hello
```

源码：

```
main.cpp
```

类似：

以前：

```bash
g++ main.cpp -o hello
```

现在：

CMake：

```cmake
add_executable(
hello
main.cpp
)
```

---

# 第5章：如何运行CMake

```shell
#不推荐的做法，直接在CMakeList.txt所在目录cmake
ly@dba13:~/HelloMake/cmakeTest$ cmake .
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
-- Configuring done (1.8s)
-- Generating done (0.0s)
-- Build files have been written to: /home/ly/HelloMake/cmakeTest
ly@dba13:~/HelloMake/cmakeTest$ ls
CMakeCache.txt  CMakeFiles  cmake_install.cmake  CMakeLists.txt  main.cpp  Makefile
#清理文件(为了测试其他)
ly@dba13:~/HelloMake/cmakeTest$ ls -d !(CMakeLists.txt||main.cpp)
CMakeCache.txt  CMakeFiles  cmake_install.cmake  Makefile
ly@dba13:~/HelloMake/cmakeTest$ rm -rf !(CMakeLists.txt||main.cpp)
ly@dba13:~/HelloMake/cmakeTest$ ls
CMakeLists.txt  main.cpp

```

推荐：

不要污染源码目录。

目录：

```
HelloCMake

├── CMakeLists.txt
├── main.cpp
└── build
```

进入：

```bash
#提前建立好build目录
cd build
```

执行：

```bash
ly@dba13:~/HelloMake/cmakeTest/build$ cmake ..
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
-- Configuring done (1.8s)
-- Generating done (0.0s)
-- Build files have been written to: /home/ly/HelloMake/cmakeTest/build
ly@dba13:~/HelloMake/cmakeTest/build$ ls
CMakeCache.txt  CMakeFiles  cmake_install.cmake  Makefile
```

> cmake主要作用，就是读取配置并生成构建文件（如 Makefile），它本身不编译代码。随后执行 make 才是调用编译器把源码编译成可执行文件


这里：

```
..
```

代表：

上一级目录。

也就是：

```
build
 |
 ↑
 HelloCMake
```

CMake读取：

```
../CMakeLists.txt
```

生成：

```
Makefile
```

```shell
#这里显示一下Makefile
ly@dba13:~/HelloMake/cmakeTest/build$ cat Makefile
# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.31

# Default target executed when no arguments are given to make.
default_target: all
.PHONY : default_target

# Allow only one "make -f Makefile2" at a time, but pass parallelism.
.NOTPARALLEL:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v 

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s
...
#============这中间内容省略了===========
.....
# target to generate assembly for a file
main.cpp.s:
	$(MAKE) $(MAKESILENT) -f CMakeFiles/hello.dir/build.make CMakeFiles/hello.dir/main.cpp.s
.PHONY : main.cpp.s

# Help Target
help:
	@echo "The following are some of the valid targets for this Makefile:"
	@echo "... all (the default if no target is provided)"
	@echo "... clean"
	@echo "... depend"
	@echo "... edit_cache"
	@echo "... rebuild_cache"
	@echo "... hello"
	@echo "... main.o"
	@echo "... main.i"
	@echo "... main.s"
.PHONY : help



#=============================================================================
# Special targets to cleanup operation of make.

# Special rule to run CMake to check the build system integrity.
# No rule that depends on this can have commands that come from listfiles
# because they might be regenerated.
cmake_check_build_system:
	$(CMAKE_COMMAND) -S$(CMAKE_SOURCE_DIR) -B$(CMAKE_BINARY_DIR) --check-build-system CMakeFiles/Makefile.cmake 0
.PHONY : cmake_check_build_system

```

然后：

```bash
ly@dba13:~/HelloMake/cmakeTest/build$ make
[ 50%] Building CXX object CMakeFiles/hello.dir/main.cpp.o
[100%] Linking CXX executable hello
[100%] Built target hello
ly@dba13:~/HelloMake/cmakeTest/build$ ls
CMakeCache.txt  CMakeFiles  cmake_install.cmake  hello  Makefile
```

生成：

```
hello
```


运行：

```bash
./hello
```

输出：

```
Hello CMake
```

---

## 一步到位

上面是先新建build目录，然后`cd build`，再用`cmake ..`，最后用`make`。可以使用`cmake -B build && cmake --build build`一步到位   ~~第1个、第3个单词build，表示文件夹名，可为任意名字，但得保持一致，比如~~   

```shell
ly@dba13:~/HelloMake/cmakeTest$ cmake -B build123 && cmake --build build123
-- Configuring done (0.1s)
-- Generating done (0.0s)
-- Build files have been written to: /home/ly/HelloMake/cmakeTest/build123
[100%] Built target hello  #这里啥都没有是因为我编译过一次了
ly@dba13:~/HelloMake/cmakeTest$ ./build123/hello
Hello CMake
```

命令解析：
1. cmake -B build：
   在 build 目录下生成构建系统（Makefile）。使用 -B build 可以避免在源码根目录产生一堆乱七八糟的临时文件（即 Out-of-source 源码外构建）。
2. &&：
   Shell 逻辑与，前一步生成成功后，紧接着执行下一句。
3. cmake --build build：
   跨平台编译命令。CMake 会自动识别刚才生成的构建工具（在 Linux 上会自动调用 make，在 Windows 上自动调用 MSBuild，如果装了 Ninja 会调用 ninja），直接开始编译并生成可执行文件。

验证方式：运行该单行命令后，你可以直接在 build/ 目录下找到编译好的可执行文件。  

```shell
ly@dba13:~/HelloMake/cmakeTest$ ./build/hello
Hello CMake
```

# 到这里你应该掌握：

## 编译链：

```
cpp
 |
编译器 gcc
 |
obj
 |
链接器
 |
exe
```

## Make：

```
Makefile
 ↓
make
 ↓
gcc
```

## CMake：

```
CMakeLists.txt
 ↓
cmake
 ↓
Makefile
 ↓
make
 ↓
gcc
```

---
------

# 下一节会进入真正重要部分：

## 第6章：CMake核心思想——target

这部分非常重要，因为现代CMake（包括ROS2、STM32、OpenCV项目）都是：

```
target思想
```

例如你之前的：

```cmake
add_executable(${PROJECT_NAME})
target_sources(
    ${PROJECT_NAME}
    PRIVATE
    Src/main.c
)
```

其实就是现代CMake写法。

下一节会详细解释：

* 什么是target
* add_executable
* add_library
* target_sources
* target_include_directories
* target_link_libraries
* PRIVATE / PUBLIC / INTERFACE

这些是看懂90%工程CMakeLists.txt的核心。
