---
title: 编译与链接
description: 编译与链接
categories:
  - 学习
tags:
  - 编译
  - 链接
  - CPP
date: 2026-09-14T22:02:16+08:00
lastmod: 2026-09-14T22:02:16+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 静态库

假设目录：

```text
project/
├── app.cpp
├── motor.cpp
└── motor.h
```

我们用**纯 g++ 命令**，不使用 CMake。

## 1. 写代码

### motor.h

```cpp
#ifndef MOTOR_H
#define MOTOR_H

void motor_run();

#endif
```

### motor.cpp

```cpp
#include <iostream>
#include "motor.h"

void motor_run()
{
    std::cout << "Motor is running!" << std::endl;
}
```

### app.cpp

```cpp
#include "motor.h"

int main()
{
    motor_run();
    return 0;
}
```

---

## 2. 先把 motor.cpp 编译成库

这里可以编译成两种库：

* 静态库：`libmotor.a`
* 动态库：`libmotor.so`

先看最简单的**静态库**。

### 第一步：motor.cpp → motor.o

```bash
g++ -c motor.cpp -o motor.o
```

得到：

```text
motor.o
```

这里 `-c` 的意思是：

> 只编译，不进行最终链接。

---

### 第二步：motor.o → libmotor.a

使用 `ar`：

```bash
ar rcs libmotor.a motor.o
```

| 参数  | 含义                |
| --- | ----------------- |
| `r` | replace，添加/替换目标文件 |
| `c` | create，如果库不存在就创建  |
| `s` | 建立符号索引，方便链接器查找    |

得到：

```text
libmotor.a
```

所以现在：

```text
project/
├── app.cpp
├── motor.cpp
├── motor.h
├── motor.o
└── libmotor.a
```

其中：

```text
motor.cpp
   │
   │ g++ -c
   ↓
motor.o
   │
   │ ar rcs
   ↓
libmotor.a
```

---

## 3. app.cpp + libmotor.a 编译成最终程序

现在：

```bash
#=============此时可以不需要.o文件了======
╭─ ~/ly_vscode/HelloCMake/12_1 main ?1
╰─❯ rm -rf motor.o

╭─ ~/ly_vscode/HelloCMake/12_1 main ?1
╰─❯ ls
app.cpp  libmotor.a  motor.cpp  motor.h
#=============此时可以不需要.o文件了======

╭─ ~/ly_vscode/HelloCMake/12_1 main ?1
╰─❯ g++ app.cpp -L. -lmotor -o app

╭─ ~/ly_vscode/HelloCMake/12_1 main ?1
╰─❯ ./app
Motor is running!
```

最终得到：

```text
app
```

由于是静态库，此时可以把`.o`和`.a`和删掉再运行程序也没问题  

```bash
╭─ ~/ly_vscode/HelloCMake/12_1 main ?1
╰─❯ ls
app  app.cpp  motor.cpp  motor.h

╭─ ~/ly_vscode/HelloCMake/12_1 main ?1
╰─❯ ./app
Motor is running!
```

运行：

```bash
./app
```

输出：

```text
Motor is running!
```

---

## 4. 这里的 `-L.` 和 `-lmotor` 是什么意思？

这是理解这个过程的关键。

```bash
g++ app.cpp -L. -lmotor -o app
```

### `-L.`

告诉 g++：

> 去当前目录寻找库。

因为我们的：

```text
libmotor.a
```

就在当前目录。

#### 如果不在当前目录

```bash
╭─ ~/ly_vscode/HelloCMake/12_1 main ?1
╰─❯ tree
.
├── app.cpp
├── motor.cpp
├── motor.h
└── mylib
    └── libmotor.a

2 directories, 4 files

╭─ ~/ly_vscode/HelloCMake/12_1 main ?1
╰─❯ g++ app.cpp -L. -lmotor -o app
/usr/bin/ld: cannot find -lmotor: No such file or directory
collect2: error: ld returned 1 exit status

#.L后直接写路径，也可以是绝对路径
╭─ ~/ly_vscode/HelloCMake/12_1 main ?1
╰─❯ g++ app.cpp -Lmylib -lmotor -o app 

╭─ ~/ly_vscode/HelloCMake/12_1 main ?1
╰─❯ ./app
Motor is running!
```

---

### `-lmotor`

告诉 g++：

> 链接名为 motor 的库。

注意你实际的文件叫：

```text
libmotor.a
```

但是写：

```bash
-lmotor
```

而不是：

```bash
-llibmotor.a
```

g++ 会按照类似这样的规则寻找：

```text
libmotor.a
libmotor.so
```

所以：

```bash
-lmotor
```

≈

```text
寻找 libmotor.a / libmotor.so
```

---

## 5. 也可以直接指定库文件

实际上你甚至可以不使用 `-L` 和 `-l`：

```bash
g++ app.cpp ./libmotor.a -o app
```

这也可以。

完整过程就是：

```bash
g++ -c motor.cpp -o motor.o

ar rcs libmotor.a motor.o

g++ app.cpp ./libmotor.a -o app
```

这个对于理解**“先生成库，再让 app 链接库”**非常直观。

---

## 6. 如果想把头文件也放到 include 目录

实际项目通常会这样：

```text
project/
├── app.cpp
├── motor/
│   ├── motor.cpp
│   └── motor.h
└── lib/
```

可以：

```bash
g++ -c motor/motor.cpp -o motor.o

ar rcs lib/libmotor.a motor.o

╭─ ~/ly_vscode/HelloCMake/12_2 main ?2
╰─❯ g++ app.cpp -Llib -lmotor -o app
app.cpp:1:10: fatal error: motor.h: No such file or directory
    1 | #include "motor.h"
      |          ^~~~~~~~~
compilation terminated.

#所以才要指定头文件路径
g++ app.cpp -Imotor -Llib -lmotor -o app
```

这里：

```text
-I motor
```

表示：

> 去 motor/ 里面寻找头文件。

而：

```text
-L lib
```

表示：

> 去 lib/ 里面寻找库。

所以最终：

```text
                 ┌── motor.cpp
                 │
                 ↓
             g++ -c
                 │
                 ↓
              motor.o
                 │
                 ↓
              ar rcs
                 │
                 ↓
            libmotor.a
                 │
                 │
app.cpp ─────────┤
                 ↓
            g++ 链接
                 │
                 ↓
                app
```

**注意一个很容易混淆的点：**

```text
#include "motor.h"
```

解决的是**编译阶段找到声明**的问题；

```text
-lmotor
```

解决的是**链接阶段找到函数实现**的问题。

也就是说：

```text
motor.h
   ↓
告诉 app.cpp：
“motor_run() 这个函数存在”

libmotor.a
   ↓
告诉链接器：
“motor_run() 的真正实现就在这里”
```

这也是为什么你前面学习 CMake 时，会看到 `target_include_directories()` 和 `target_link_libraries()` 分别负责不同事情。

# 动态库

刚才只讲了**静态库**。动态库的流程基本一样，只是生成库的方式和最终运行时的行为不同。

还是：

```text
app.cpp
motor.cpp
motor.h
```

## 1. 编译 `motor.cpp` 为动态库

动态库要求生成位置无关代码，所以加 `-fPIC`：

```bash
g++ -fPIC -c motor.cpp -o motor.o
```

然后生成 `.so`：

```bash
g++ -shared motor.o -o libmotor.so
```

于是：

```text
motor.cpp
    ↓
g++ -fPIC -c
    ↓
motor.o
    ↓
g++ -shared
    ↓
libmotor.so
```

目录：

```text
project/
├── app.cpp
├── motor.cpp
├── motor.h
├── motor.o
└── libmotor.so
```

---

## 2. 编译 app，并链接动态库

```bash
g++ app.cpp -L. -lmotor -o app
```

这里和静态库的命令**几乎一模一样**：

```bash
g++ app.cpp -L. -lmotor -o app
```

区别在于当前目录存在的是：

```text
libmotor.so
```

所以链接器会使用动态库。

---

## 3. 但是这里有一个重要问题

直接运行：

```bash
./app
```

可能会出现：

```text
./app: error while loading shared libraries: libmotor.so:
cannot open shared object file: No such file or directory
```

为什么？

因为：

```bash
-L.
```

只告诉**链接阶段**：

> 去当前目录找 `libmotor.so`。

但是程序运行以后，Linux 的**动态加载器**还需要知道：

> `libmotor.so` 到底在哪里？

你可以临时这样运行：

```bash
#同样这里之前就可以移除.o文件了
LD_LIBRARY_PATH=. ./app
```


这时候就可以找到当前目录的：

```text
./libmotor.so
```

```shell
#如果移动到其他目录，也很简单
╭─ ~/ly_vscode/HelloCMake/12_3 main ?3
╰─❯ tree
.
├── app
├── app.cpp
├── motor.cpp
├── motor.h
└── mylib
    └── libmotor.so

2 directories, 5 files

╭─ ~/ly_vscode/HelloCMake/12_3 main ?3
╰─❯ ./app
./app: error while loading shared libraries: libmotor.so: cannot open shared object file: No such file or directory

╭─ ~/ly_vscode/HelloCMake/12_3 main ?3
╰─❯ LD_LIBRARY_PATH=. ./app
./app: error while loading shared libraries: libmotor.so: cannot open shared object file: No such file or directory

╭─ ~/ly_vscode/HelloCMake/12_3 main ?3
╰─❯ LD_LIBRARY_PATH=mylib ./app
Motor is running!
```

### shell的特殊写法


```
变量=值 程序 参数...
```

表示：

> 用这个环境变量启动后面的程序。

例如：

```
FOO=hello ./app
```

程序 app 启动后就能读取：

```
getenv("FOO")
```

得到：

```
hello
```


## 4. 所以完整过程

动态库：

```bash
g++ -fPIC -c motor.cpp -o motor.o

g++ -shared motor.o -o libmotor.so

g++ app.cpp -L. -lmotor -o app

LD_LIBRARY_PATH=. ./app
```

输出：

```text
Motor is running!
```

---

# 静态库和动态库对比

你现在可以把两套流程放在一起看：

## 静态库

```bash
g++ -c motor.cpp -o motor.o
ar rcs libmotor.a motor.o

g++ app.cpp -L. -lmotor -o app

./app
```

最终：

```text
app
 │
 ├── 自己的代码
 │
 └── motor_run()的代码
      ↑
      已经被复制/链接进 app
```

所以运行时**不需要 `libmotor.a`**。

---

## 动态库

```bash
g++ -fPIC -c motor.cpp -o motor.o
g++ -shared motor.o -o libmotor.so

g++ app.cpp -L. -lmotor -o app

LD_LIBRARY_PATH=. ./app
```

最终：

```text
app
 │
 └── 记录：
      “我需要 libmotor.so”
               │
               ↓
          libmotor.so
```

运行时需要：

```text
app
libmotor.so
```

二者都存在。

---

### 为什么动态库需要 `-fPIC`？

简单理解：

```bash
g++ -fPIC -c motor.cpp
```

告诉编译器：

> 生成适合放进共享库的代码。

`PIC` 就是：

**Position Independent Code**

即**位置无关代码**。

***因为 `libmotor.so` 可能被不同程序加载到内存的不同位置，所以它里面的代码最好不要依赖“我一定被放在某个固定地址”***。


### 还有一个更实用的写法：把库路径写进程序

不想每次：

```bash
LD_LIBRARY_PATH=. ./app
```

可以在链接时加：

```bash
#放做对比，这是没有加的
#g++ app.cpp -L. -lmotor -o app

g++ app.cpp -L. -Wl,-rpath,'$ORIGIN' -lmotor -o app
```

这里：

```text
$ORIGIN
```

表示：

> 当前可执行文件所在的目录。

那么：

```text
project/
├── app
└── libmotor.so
```

直接：

```bash
./app
```

就能找到旁边的 `libmotor.so`。
#### 解释 `-Wl,-rpath,'$ORIGIN'`

`-Wl,-rpath,'$ORIGIN'`是告诉 链接器：***把一个运行时动态库搜索路径写进 app 本身。***

拆开看就很清楚：

```
-Wl,             传递参数给 ld 链接器
    -rpath,      设置运行时动态库搜索路径
           $ORIGIN  表示“可执行文件所在的目录”
```

- -Wl, 是什么？
  g++ 本身不是最终负责链接的程序，它会调用 GNU linker，也就是：

```
ld
```

所以：

```
-Wl,参数
```

意思就是：

> 把后面的参数传给 ld。

例如：

```
-Wl,-rpath,...
```

实际上就是让 g++ 最终调用 ld 时带上：

```
-rpath ...
```

注意这里的逗号：

```
-Wl,-rpath,'$ORIGIN'
     ↑
```

-Wl, 后面的内容是传给 ld 的参数列表。

## 总结

所以你可以记住这一张表：

|           | 静态库          | 动态库                       |
| --------- | ------------ | ------------------------- |
| 库文件       | `libmotor.a` | `libmotor.so`             |
| 编译 `.cpp` | `g++ -c`     | `g++ -fPIC -c`            |
| 制作库       | `ar rcs`     | `g++ -shared`             |
| 链接        | `-lmotor`    | `-lmotor`                 |
| 运行时需要库    | ❌            | ✅                         |
| 典型运行      | `./app`      | `LD_LIBRARY_PATH=. ./app` |

**特别值得注意的是：`-L` 和 `LD_LIBRARY_PATH` 不是一回事。**

```text
-L.
   ↓
编译/链接的时候找库

LD_LIBRARY_PATH=.
   ↓
程序运行的时候找动态库
```

这两个概念后面学 Linux 动态链接时非常重要。


# ar

`ar` 是 Linux/Unix 下的一个**归档工具（archiver）**，最常见的用途就是：

> **把多个 `.o` 目标文件打包成一个静态库 `.a` 文件。**

你刚才这个例子里：

```bash
g++ -c motor.cpp -o motor.o
```

得到：

```text
motor.o
```

然后：

```bash
ar rcs libmotor.a motor.o
```

得到：

```text
libmotor.a
```

所以可以简单理解成：

```text
motor.cpp
   ↓ g++
motor.o
   ↓ ar
libmotor.a
```

## `ar` 本质上干什么？

例如你有：

```text
motor.o
servo.o
sensor.o
```

可以：

```bash
ar rcs librobot.a motor.o servo.o sensor.o
```

得到：

```text
librobot.a
```

这个 `librobot.a` **本质上就是一个包含多个 `.o` 文件的归档文件**。

然后：

```bash
g++ app.cpp -L. -lrobot -o app
```

链接器就可以从 `librobot.a` 中找到 `app.cpp` 所需要的函数实现。

---

## `ar rcs` 中三个字母什么意思？

```bash
ar rcs libmotor.a motor.o
```

可以粗略理解：

| 参数  | 含义                |
| --- | ----------------- |
| `r` | replace，添加/替换目标文件 |
| `c` | create，如果库不存在就创建  |
| `s` | 建立符号索引，方便链接器查找    |

所以最常见的静态库创建命令就是：

```bash
ar rcs libxxx.a xxx.o
```

---

## `ar` 和 `g++` 的关系

这点非常重要：

```bash
g++ -c motor.cpp -o motor.o
```

负责：

> **源代码 → 目标文件**

而：

```bash
ar rcs libmotor.a motor.o
```

负责：

> **目标文件 → 静态库**

最后：

```bash
g++ app.cpp libmotor.a -o app
```

负责：

> **编译 + 链接 → 可执行文件**

因此整个过程是：

```text
          编译
motor.cpp ───────→ motor.o
                     │
                     │ ar
                     ↓
                  libmotor.a
                     │
                     │ 链接
app.cpp ─────────────┘
                     ↓
                    app
```

所以你可以把 **`ar` 简单记成：专门用来制作/管理 `.a` 静态库的工具**。
