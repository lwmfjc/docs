---
title: 06_CMake核心思想_target
description: 06_CMake核心思想_target
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
***第6章：CMake核心思想 —— target（目标）***


很好，前五章其实已经把 CMake 最容易混淆的几个基础概念铺好了：

你现在应该已经知道：

```
C++源码
   |
   | 编译
   ↓
.o目标文件
   |
   | 链接
   ↓
可执行文件


Make:
Makefile → make → gcc


CMake:
CMakeLists.txt → cmake → Makefile/Ninja → gcc
```

并且理解了：

* **`.cpp` 是源码**
* **`.so/.a` 是库**
* **target 不是文件，而是 CMake 管理的构建对象**
* **CMake核心不是管理文件，而是管理 target 关系**

第六章非常重要。

因为现代 CMake（ROS2、OpenCV、Qt、LLVM、STM32很多工程）基本都是围绕 target 写的。

---

# 6.1 什么是target？

先看传统Make思维。

以前写Make：

```makefile
app:
	g++ main.cpp math.cpp -o app
```

你关注：

> 哪些文件？

所以是：

```
文件 → 命令 → 输出
```

---

现代CMake：

```cmake
add_executable(
    app

    main.cpp
    math.cpp
)
```

关注：

```
创建一个目标：

app
```

然后：

```cmake
target_link_libraries(
    app
    xxx
)
```

意思：

```
app依赖xxx
```

所以变成：

```
target
 |
 |依赖
 |
target
```

---

# 6.2 CMake有哪些target？

主要三类：

## 1. 可执行文件 target

最终生成：

```
.exe
Linux可执行文件
```

创建：

```cmake
add_executable()
```

例如：

```cmake
add_executable(
    robot

    main.cpp
)
```

产生：

```
robot
```

---

## 2. 静态库 target

生成：

Linux：

```
libxxx.a
```

Windows：

```
xxx.lib
```

创建：

```cmake
add_library()
```

例如：

目录：

```
project

├── main.cpp
├── math.cpp
└── math.h
```

我们把数学功能单独做库：

```cmake
add_library(
    math

    math.cpp
)
```

生成：

```
libmath.a
```

然后：

```cmake
add_executable(
    app

    main.cpp
)


target_link_libraries(
    app

    math
)
```

关系：

```
        app

         |
         |
       依赖

         ↓

       math库
```

---

## 3. 动态库 target

生成：

Linux：

```
libxxx.so
```

Windows：

```
xxx.dll
```

例如：

```cmake
add_library(
    math

    SHARED

    math.cpp
)
```

这里：

```
SHARED
```

表示动态库。

---

# 6.3 一个完整例子

假设：

```
Calculator

├── CMakeLists.txt
├── main.cpp
└── math.cpp
```

---

main.cpp:

```cpp
#include "math.h"
#include <iostream>


int main()
{
    std::cout<<add(1,2);

    return 0;
}
```

math.cpp:

```cpp
int add(int a,int b)
{
    return a+b;
}
```

math.h：

```c
int add(int,int);
```

---

传统写法：

```cmake
add_executable(
    app

    main.cpp
    math.cpp
)
```

直接把两个cpp编进去。

结果：

```
main.cpp
     |
math.cpp
     |
     ↓
   app
```

---

但是大型项目一般不会这么写。

而是：

先创建库：

```cmake
add_library(
    math

    math.cpp
)
```

然后：

创建程序：

```cmake
add_executable(
    app

    main.cpp
)
```

最后：

连接：

```cmake
target_link_libraries(
    app

    math
)
```

完整：

```cmake
cmake_minimum_required(VERSION 3.20)

project(Calculator)


add_library(
    math

    math.cpp
)


add_executable(
    app

    main.cpp
)


target_link_libraries(
    app

    math
)
```

## 验证add_executable里有target库

**这里我有个疑惑，为什么不是：**  

```txt

ly@dba13:~/HelloMake/cmakeTest6_2$ cat CMakeLists.txt 
cmake_minimum_required(VERSION 3.20)
project(Calculator) 

add_library(
	math
	math.cpp
)

add_executable(
	app
	math #主要这里，我在add_executable掺进去了一个库!!!!!!!!!
	main.cpp
)

y@dba13:~/HelloMake/cmakeTest6_2$ mkdir build
ly@dba13:~/HelloMake/cmakeTest6_2$ ls
build  CMakeLists.txt  main.cpp  math.cpp  math.h
ly@dba13:~/HelloMake/cmakeTest6_2$ clear
ly@dba13:~/HelloMake/cmakeTest6_2$ ls build
ly@dba13:~/HelloMake/cmakeTest6_2$ ls
build  CMakeLists.txt  main.cpp  math.cpp  math.h


ly@dba13:~/HelloMake/cmakeTest6_2$ cmake --build build --verbose
Error: could not load cache
ly@dba13:~/HelloMake/cmakeTest6_2$ cmake -B build && cmake --build build --verbose
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
-- Build files have been written to: /home/ly/HelloMake/cmakeTest6_2/build
Change Dir: '/home/ly/HelloMake/cmakeTest6_2/build'

Run Build Command(s): /usr/bin/cmake -E env VERBOSE=1 /usr/bin/gmake -f Makefile
/usr/bin/cmake -S/home/ly/HelloMake/cmakeTest6_2 -B/home/ly/HelloMake/cmakeTest6_2/build --check-build-system CMakeFiles/Makefile.cmake 0
/usr/bin/cmake -E cmake_progress_start /home/ly/HelloMake/cmakeTest6_2/build/CMakeFiles /home/ly/HelloMake/cmakeTest6_2/build//CMakeFiles/progress.marks
/usr/bin/gmake  -f CMakeFiles/Makefile2 all
gmake[1]: Entering directory '/home/ly/HelloMake/cmakeTest6_2/build'
/usr/bin/gmake  -f CMakeFiles/math.dir/build.make CMakeFiles/math.dir/depend
gmake[2]: Entering directory '/home/ly/HelloMake/cmakeTest6_2/build'
cd /home/ly/HelloMake/cmakeTest6_2/build && /usr/bin/cmake -E cmake_depends "Unix Makefiles" /home/ly/HelloMake/cmakeTest6_2 /home/ly/HelloMake/cmakeTest6_2 /home/ly/HelloMake/cmakeTest6_2/build /home/ly/HelloMake/cmakeTest6_2/build /home/ly/HelloMake/cmakeTest6_2/build/CMakeFiles/math.dir/DependInfo.cmake "--color="
gmake[2]: Leaving directory '/home/ly/HelloMake/cmakeTest6_2/build'
/usr/bin/gmake  -f CMakeFiles/math.dir/build.make CMakeFiles/math.dir/build
gmake[2]: Entering directory '/home/ly/HelloMake/cmakeTest6_2/build'
[ 20%] Building CXX object CMakeFiles/math.dir/math.cpp.o
/usr/bin/c++    -MD -MT CMakeFiles/math.dir/math.cpp.o -MF CMakeFiles/math.dir/math.cpp.o.d -o CMakeFiles/math.dir/math.cpp.o -c /home/ly/HelloMake/cmakeTest6_2/math.cpp
[ 40%] Linking CXX static library libmath.a  #========这里创建了一个链接库===========
/usr/bin/cmake -P CMakeFiles/math.dir/cmake_clean_target.cmake
/usr/bin/cmake -E cmake_link_script CMakeFiles/math.dir/link.txt --verbose=1
/usr/bin/ar qc libmath.a CMakeFiles/math.dir/math.cpp.o
/usr/bin/ranlib libmath.a
gmake[2]: Leaving directory '/home/ly/HelloMake/cmakeTest6_2/build'
[ 40%] Built target math
/usr/bin/gmake  -f CMakeFiles/app.dir/build.make CMakeFiles/app.dir/depend
gmake[2]: Entering directory '/home/ly/HelloMake/cmakeTest6_2/build'
cd /home/ly/HelloMake/cmakeTest6_2/build && /usr/bin/cmake -E cmake_depends "Unix Makefiles" /home/ly/HelloMake/cmakeTest6_2 /home/ly/HelloMake/cmakeTest6_2 /home/ly/HelloMake/cmakeTest6_2/build /home/ly/HelloMake/cmakeTest6_2/build /home/ly/HelloMake/cmakeTest6_2/build/CMakeFiles/app.dir/DependInfo.cmake "--color="
gmake[2]: Leaving directory '/home/ly/HelloMake/cmakeTest6_2/build'
/usr/bin/gmake  -f CMakeFiles/app.dir/build.make CMakeFiles/app.dir/build
gmake[2]: Entering directory '/home/ly/HelloMake/cmakeTest6_2/build'
[ 60%] Building CXX object CMakeFiles/app.dir/math.cpp.o
/usr/bin/c++    -MD -MT CMakeFiles/app.dir/math.cpp.o -MF CMakeFiles/app.dir/math.cpp.o.d -o CMakeFiles/app.dir/math.cpp.o -c /home/ly/HelloMake/cmakeTest6_2/math.cpp
[ 80%] Building CXX object CMakeFiles/app.dir/main.cpp.o
/usr/bin/c++    -MD -MT CMakeFiles/app.dir/main.cpp.o -MF CMakeFiles/app.dir/main.cpp.o.d -o CMakeFiles/app.dir/main.cpp.o -c /home/ly/HelloMake/cmakeTest6_2/main.cpp
[100%] Linking CXX executable app
/usr/bin/cmake -E cmake_link_script CMakeFiles/app.dir/link.txt --verbose=1
/usr/bin/c++ -Wl,--dependency-file=CMakeFiles/app.dir/link.d CMakeFiles/app.dir/math.cpp.o CMakeFiles/app.dir/main.cpp.o -o app  #注意这里是 CMakeFiles/app.dir/math.cpp.o而不是CMakeFiles/math.dir/math.cpp.o，并且压根就没有libmath.a
gmake[2]: Leaving directory '/home/ly/HelloMake/cmakeTest6_2/build'
[100%] Built target app
gmake[1]: Leaving directory '/home/ly/HelloMake/cmakeTest6_2/build'
/usr/bin/cmake -E cmake_progress_start /home/ly/HelloMake/cmakeTest6_2/build/CMakeFiles 0


ly@dba13:~/HelloMake/cmakeTest6_2$ ./build/app
3
```

你这次的 `VERBOSE=1` 输出已经**完全确认了**：你的 `app` **没有链接 math 库**，而是**直接把 `math.cpp` 编译进了 app**。

关键证据就在这里：

### 1. `math` 库确实被创建了

前面：

```text
[ 20%] Building CXX object CMakeFiles/math.dir/math.cpp.o
...
[ 40%] Linking CXX static library libmath.a
...
/usr/bin/ar qc libmath.a CMakeFiles/math.dir/math.cpp.o
```

说明：

```cmake
add_library(
    math
    math.cpp
)
```

生成了：

```
libmath.a
```

也就是说：

```
math.cpp
   |
   v
CMakeFiles/math.dir/math.cpp.o
   |
   v
libmath.a
```

这个库存在。

---

### 2. 但是 app 没有使用 libmath.a

看 app 的编译：

```text
[ 60%] Building CXX object CMakeFiles/app.dir/math.cpp.o
```

注意：

不是：

```
CMakeFiles/math.dir/math.cpp.o
```

而是：

```
CMakeFiles/app.dir/math.cpp.o
```

这两个完全不同。

说明：

`math.cpp` 又被重新编译了一次，属于 app 自己。

结构变成：

```
math.cpp
   |
   +----> math target
   |          |
   |          v
   |       libmath.a
   |
   +----> app target
              |
              v
          math.cpp.o
```

---

### 3. 最终链接命令是决定性证据

你的最后：

```text
/usr/bin/c++ 
CMakeFiles/app.dir/math.cpp.o 
CMakeFiles/app.dir/main.cpp.o 
-o app
```

注意：

这里没有：

```
libmath.a
```

如果链接库，应该类似：

```
/usr/bin/c++
CMakeFiles/app.dir/main.cpp.o
-o app
libmath.a
```

但是你的：

```
math.cpp.o
main.cpp.o
```

直接生成：

```
app
```

所以结论：

> `add_executable(app math main.cpp)` 中的 `math` 被解析成了 **已经存在的 target 的源文件集合**，不是链接库。

---

### 为什么 CMake 允许这样写？

这是 CMake 的一个特性：

`add_executable()` 的源文件列表里面，可以放：

1. 源文件：

```cmake
add_executable(app main.cpp)
```

2. 另一个 target：

```cmake
add_library(math math.cpp)

add_executable(
    app
    math
    main.cpp
)
```

当你写：

```cmake
app math
```

CMake 发现：

已经有一个 target：

```
math
```

于是把它展开：

```
math
 |
 +--- math.cpp
```

相当于：

```cmake
add_executable(
    app
    math.cpp
    main.cpp
)
```

---

### 注意一个细节：重复编译

你这个例子里面：

```cmake
add_library(math math.cpp)

add_executable(
    app
    math
    main.cpp
)
```

实际上创建了两个独立的编译：

第一次：

```
math.cpp
    |
    v
libmath.a
```

第二次：

```
math.cpp
    |
    v
app
```

所以：

* `libmath.a` 生成了
* 但是没人用它

属于**重复编译**。

---

### 验证链接库，改成：

```cmake
cmake_minimum_required(VERSION 3.20)

project(Calculator)

add_library(
    math
    math.cpp
)
#相当于
add_library(
    math
    STATIC #相对的SHARED 是动态库
    math.cpp
)

add_executable(
    app
    main.cpp
)

target_link_libraries(
    app
    math
)
```

然后：

```bash
rm -rf build
ly@dba13:~/HelloMake/cmakeTest6_2$ ls
CMakeLists.txt  main.cpp  math.cpp  math.h
ly@dba13:~/HelloMake/cmakeTest6_2$ cat CMakeLists.txt 
cmake_minimum_required(VERSION 3.20)

project(Calculator)

add_library(
    math
    math.cpp
)

add_executable(
    app
    main.cpp
)

target_link_libraries(
    app
    math
)
ly@dba13:~/HelloMake/cmakeTest6_2$ cmake -B build && cmake --build build --verbose
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
-- Build files have been written to: /home/ly/HelloMake/cmakeTest6_2/build
Change Dir: '/home/ly/HelloMake/cmakeTest6_2/build'

Run Build Command(s): /usr/bin/cmake -E env VERBOSE=1 /usr/bin/gmake -f Makefile
/usr/bin/cmake -S/home/ly/HelloMake/cmakeTest6_2 -B/home/ly/HelloMake/cmakeTest6_2/build --check-build-system CMakeFiles/Makefile.cmake 0
/usr/bin/cmake -E cmake_progress_start /home/ly/HelloMake/cmakeTest6_2/build/CMakeFiles /home/ly/HelloMake/cmakeTest6_2/build//CMakeFiles/progress.marks
/usr/bin/gmake  -f CMakeFiles/Makefile2 all
gmake[1]: Entering directory '/home/ly/HelloMake/cmakeTest6_2/build'
/usr/bin/gmake  -f CMakeFiles/math.dir/build.make CMakeFiles/math.dir/depend
gmake[2]: Entering directory '/home/ly/HelloMake/cmakeTest6_2/build'
cd /home/ly/HelloMake/cmakeTest6_2/build && /usr/bin/cmake -E cmake_depends "Unix Makefiles" /home/ly/HelloMake/cmakeTest6_2 /home/ly/HelloMake/cmakeTest6_2 /home/ly/HelloMake/cmakeTest6_2/build /home/ly/HelloMake/cmakeTest6_2/build /home/ly/HelloMake/cmakeTest6_2/build/CMakeFiles/math.dir/DependInfo.cmake "--color="
gmake[2]: Leaving directory '/home/ly/HelloMake/cmakeTest6_2/build'
/usr/bin/gmake  -f CMakeFiles/math.dir/build.make CMakeFiles/math.dir/build
gmake[2]: Entering directory '/home/ly/HelloMake/cmakeTest6_2/build'
[ 25%] Building CXX object CMakeFiles/math.dir/math.cpp.o
/usr/bin/c++    -MD -MT CMakeFiles/math.dir/math.cpp.o -MF CMakeFiles/math.dir/math.cpp.o.d -o CMakeFiles/math.dir/math.cpp.o -c /home/ly/HelloMake/cmakeTest6_2/math.cpp
[ 50%] Linking CXX static library libmath.a  #生成（打包）静态库
/usr/bin/cmake -P CMakeFiles/math.dir/cmake_clean_target.cmake
/usr/bin/cmake -E cmake_link_script CMakeFiles/math.dir/link.txt --verbose=1
/usr/bin/ar qc libmath.a CMakeFiles/math.dir/math.cpp.o   
/usr/bin/ranlib libmath.a 
gmake[2]: Leaving directory '/home/ly/HelloMake/cmakeTest6_2/build'
[ 50%] Built target math
/usr/bin/gmake  -f CMakeFiles/app.dir/build.make CMakeFiles/app.dir/depend
gmake[2]: Entering directory '/home/ly/HelloMake/cmakeTest6_2/build'
cd /home/ly/HelloMake/cmakeTest6_2/build && /usr/bin/cmake -E cmake_depends "Unix Makefiles" /home/ly/HelloMake/cmakeTest6_2 /home/ly/HelloMake/cmakeTest6_2 /home/ly/HelloMake/cmakeTest6_2/build /home/ly/HelloMake/cmakeTest6_2/build /home/ly/HelloMake/cmakeTest6_2/build/CMakeFiles/app.dir/DependInfo.cmake "--color="
gmake[2]: Leaving directory '/home/ly/HelloMake/cmakeTest6_2/build'
/usr/bin/gmake  -f CMakeFiles/app.dir/build.make CMakeFiles/app.dir/build
gmake[2]: Entering directory '/home/ly/HelloMake/cmakeTest6_2/build'
[ 75%] Building CXX object CMakeFiles/app.dir/main.cpp.o #===app的编译，这里没有了math.cpp.o ===
/usr/bin/c++    -MD -MT CMakeFiles/app.dir/main.cpp.o -MF CMakeFiles/app.dir/main.cpp.o.d -o CMakeFiles/app.dir/main.cpp.o -c /home/ly/HelloMake/cmakeTest6_2/main.cpp
[100%] Linking CXX executable app 
/usr/bin/cmake -E cmake_link_script CMakeFiles/app.dir/link.txt --verbose=1
/usr/bin/c++ -Wl,--dependency-file=CMakeFiles/app.dir/link.d CMakeFiles/app.dir/main.cpp.o -o app  libmath.a  #======最后的链接========
gmake[2]: Leaving directory '/home/ly/HelloMake/cmakeTest6_2/build'
[100%] Built target app
gmake[1]: Leaving directory '/home/ly/HelloMake/cmakeTest6_2/build'
/usr/bin/cmake -E cmake_progress_start /home/ly/HelloMake/cmakeTest6_2/build/CMakeFiles 0

```

你应该看到：

```text
Building CXX object CMakeFiles/math.dir/math.cpp.o

Linking CXX static library libmath.a


Building CXX object CMakeFiles/app.dir/main.cpp.o

Linking CXX executable app

/usr/bin/c++
CMakeFiles/app.dir/main.cpp.o
-o app
libmath.a
```

这才是：

```
main.cpp
    |
    v
   app
    |
    v
 libmath.a
    |
    v
 math.cpp
```

---

你的这个实验非常好，实际上验证了 CMake 中一个比较冷门但重要的概念：

> **target 可以作为源集合被另一个 target 使用，但这和链接依赖（target_link_libraries）完全不是一回事。**

很多人学 CMake 时会把这两个概念混淆，你现在已经通过 `VERBOSE=1` 把它们区分开了。

```shell
ly@dba13:~/HelloMake/cmakeTest6_2/build$ ls
app  CMakeCache.txt  CMakeFiles  cmake_install.cmake  libmath.a  Makefile
#生成的静态库 libmath.a
```

# 6.4 为什么要拆成库？

你可能会问：

> 我直接把math.cpp放进去不行吗？为什么多此一举？

小项目：

确实可以。

但是大型项目：

比如ROS2：

```
robot_driver

    |
    |
    +---- hardware_interface库

    |
    |
    +---- sensor_driver库

    |
    |
    +---- navigation库

    |
    |
    +---- main程序
```

你不可能：

```cmake
add_executable(
robot

a.cpp
b.cpp
c.cpp
d.cpp
e.cpp
......
)
```

会非常混乱。

拆成：

```
driver库

navigation库

vision库

robot程序
```

关系清晰。

---

# 6.5 target最大的价值：传递属性

这是现代CMake最重要的地方。

例如：

OpenCV：

```
OpenCV target

里面保存：

头文件路径

/usr/include/opencv4


库文件：

libopencv_core.so


编译参数：

-Dxxx

依赖：

pthread
```

你的：

```
robot target
```

依赖：

```
OpenCV target
```

于是：

```
robot
 |
 |
依赖
 |
 ↓
OpenCV
```

CMake自动把：

```
头文件路径
库路径
编译参数
```

传过去。

这就是为什么现代CMake喜欢：

```cmake
target_link_libraries()
```

而不是：

```cmake
include_directories()
link_directories()
```

---

# 6.6 你之前STM32 CMake里的例子

你之前有：

```cmake
add_executable(${PROJECT_NAME})
```

这里：

创建：

```
STM32Test target
```

然后：

```cmake
target_sources(
    ${PROJECT_NAME}

    PRIVATE

    Src/main.c
)
```

意思：

给这个target添加源码。

等价：

```cmake
add_executable(
    STM32Test

    Src/main.c
)
```

只是现代写法更推荐：

先创建target：

```cmake
add_executable(app)
```

后面慢慢添加：

```cmake
target_sources(app ...)
```

---

# 本章总结

记住这几个：

## 创建可执行程序：

```cmake
add_executable(
    名字
    源文件
)
```

例如：

```cmake
add_executable(
    robot

    main.cpp
)
```

---

## 创建库：

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

## 建立依赖：

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

# 下一章会讲： 第7章：target_sources、target_include_directories —— 管理源码和头文件

这一章会直接解决你之前看到的：

```cmake
target_sources(
    ${PROJECT_NAME}

    PRIVATE

    Src/main.c
)
```

以及：

```cmake
target_include_directories()
```

到底是什么意思。

这两个是你看 STM32、ROS2、OpenCV CMakeLists 最常遇到的命令。你现在学到这里，已经开始进入真正工程里的 CMake 了。
