---
title: 01-欢迎
description: 01-欢迎
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-01T09:22:51+08:00
lastmod: 2026-10-01T09:22:51+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 欢迎

> 良好的课程和教程，知道起步阶段什么最重要

![](img/ly-20261001163409325.png)  
> 循序渐进，便于初学者追随，通过大量实践直切要点。课程结束时将掌握ROS2基础知识，并运用所有ROS2核心概念创建一个完整机器人应用

> 课程中不仅会看到怎么做，还有为什么

> 将学习在Ubuntu安装、配置ROS2，如何创建、构建和使用ROS2节点、主题、服务、消息、参数、启动文件等。一些ROS工具

> 通过众多活动进行大量练习，一同编写代码、讲解每一个步骤、布置挑战，在关键概念上不断精进。所有代码都是用Python和C++两种语言编写

> 最后会通过trutlesim完成完成的ROS2项目，综合运用本课程所学全部内容

turtlesim 是 ROS 官方提供的最简单模拟环境，主要用于学习 ROS2 基础概念，不是真正的机器人仿真。它相当于 ROS2 的“Hello World”。

它模拟的是：
- 一个二维窗口
- 一只小乌龟（turtle）
- 你可以通过 ROS2 节点控制它移动


# ROS2是什么、何时使用、为什么使用

![](img/ly-20261001171245327.png)  

> ROS2，RobotOperatingSystem，介于中间件和框架之间的东西，专为机器人应用而构建

> ROS目标：为机器人应用提供标准，让开发者可以在任何机器人上使用和复用

> 需要掌握**基础知识**和**核心功能**  

## 何时使用

> 当为新机器人编程时，会积累更多应用于其他机器人的技能

> 每当你想要创建一个需要在子程序之间进行大量通信的机器人软件，或者他的功能超出简单应用场景就可以使用它

## 是什么

> 提供了将代码分离成可复用模块的方法，并提供了一套通信工具，以便在所有子程序之间轻松通信

> 假设编程移动机器人，可以用摄像头创建一个称为节点的子程序，为导航算法创建另一个节点，为硬件驱动程序再创建一个等等。得益于ROS2的通信机制，这些独立的模块彼此之间可以通信

![](img/ly-20261001173111241.png)  
> ROS2提供许多工具和即插即用库 ~~防止重复造轮子~~ 

![](img/ly-20261001173204915.png)  

> 和语言无关，可以用Python编写一部分，CPP编写另一部分

> 本课程会专注于ROS2的基础知识、核心功能、以及那些工具，让你能够使用Python和CPP轻松启动任何由ROS2驱动的机器人应用

# 使用哪个ROS2发行版

https://docs.ros.org/en/rolling/Releases.html 

| Distro            | Release date     | Logo                  | EOL date         | ROS Boss                        |
| ----------------- | ---------------- | --------------------- | ---------------- | ------------------------------- |
| **Lyrical Luth**  | **May 22, 2026** | Lyrical Luth Logo     | **May 2031**     | **Shane Loretz**                |
| Kilted Kaiju      | May 23, 2025     | Kilted Kaiju Logo     | December 2026    | Scott K Logan                   |
| **Jazzy Jalisco** | **May 23, 2024** | Jazzy Jalisco Logo    | **May 2029**     | **Marco A. Gutiérrez**          |
| Iron Irwini       | May 23, 2023     | Iron Irwini Logo      | December 4, 2024 | Yadunund Vijay                  |
| Humble Hawksbill  | May 23, 2022     | Humble Hawksbill Logo | May 2027         | Christophe Bédard / Audrow Nash |

本视频课程发布时，最新的是 Jazzy，所以这里使用的是Jazzy

~~如果最新的LTS已经发布3-6个月了，就可以直接使用最新的LTS版本好了。~~   

> 对于Jazzy

一级平台：

- Ubuntu 24.04 (Noble)： amd64 和 arm64  ~~这里我用的wsl2装的ubuntu24.04~~ 
- Windows 10（Visual Studio 2019）： amd64 

> 对于lyrical

- Ubuntu Resolute (26.04) 
- Windows 11 (VS2022) 

# 虚拟机上安装Ubuntu24.04

> 这里我是在windows11上的wsl2，安装的Ubuntu24.04

```python
sudo apt update
sudo apt upgrade

╭─ ~/ros2_test                     
╰─❯ sudo apt install build-essential gcc make perl dkms -y


```

# 本课程使用的编程工具

由于我使用的是windows11 的 wsl2安装的Ubuntu24.04，这里附上分屏的一些快捷键

- 上下分屏： Alt + Shift + -
- 左右分屏： Alt + Shift + +
- 取消当前分屏： Ctrl + Shift + W 
- 调整当前面板大小：Alt + Shift + 方向键（左/右/上/下）
- 切换窗格缩放 ~~最大化某个窗格~~ ：Alt+Shif+Z

VSCODE安装扩展：CMake，以及ROS  

```bash
#编辑简单的文件
╭─ ~/ros2_test
╰─❯ sudo apt install gedit -y
```

> 本课程编辑简单的文本使用的是 gedit

# ubuntu24.04安装Jazzy

