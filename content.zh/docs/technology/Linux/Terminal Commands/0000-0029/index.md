---
title: 0000-0029
description: 0000-0029
categories:
  - 学习
tags:
  - Linux
  - Command
date: 2024-12-24T15:11:20+08:00
lastmod: 2024-12-24T15:11:20+08:00
---
这个系列只有一个长达五个多小时的视频，所以以时间0102(第1小时第2分钟)这样的形式命名    
 本视频参考了TheLinuxCommandsHandbook    
# 意义
更快，自动化，在任何Linux上工作，有些工作的基本需求  
# 系统-Unix和Windows
绿色-开源  
红色-闭源  
黄色-混合  
![](img/ly-20241226190213859.png)  

图片中的Linux只是类Unix，而不是真正的Unix  

# FreeSoftware，开源
GNU与Linux  
> Linux只是一个**操作系统内核**而已，而GNU提供了大量的自由软件来丰富在其之上各种应用程序。  
   绝大多数基于Linux内核的操作系统使用了大量的**GNU软件**，包括了一个shell程序、工具、程序库、编译器及工具，还有许多其他程序    
   **我们常说的Linux，准确地来讲，应该是叫“GNU/Linux”**。虽然，我们没有为GNU和Linux的开发做出什么贡献，但是我们可以为GNU和Linux的宣传和应用做出微薄的努力，至少我们能够准确地去向其他人解释清楚GNU、Linux以及GNU/Linux之间的区别。让我们一起为GNU/Linux的推广贡献出自己的力量！

内核，用来连接硬件和软件的  

# TrueUNIX

Unix一开始是收费的，后面出现Unix-like（类Unix），和Unix标准兼容。  
Linux不是真正的Unix，而是类Unix。  
Linux本身只是一个内核，连接**硬件**和**软件**  
LinuxDistributions，Linux发行版(1000多种)  
Linux内核是一些GUN工具，文档，包管理器，桌面环境窗口管理，和系统一些其他东西组成的一个系统  
![](img/ly-20241226190213859.png)  

有开源的和不开源的，Linux(LinuxGUN)完全开源  
# shell
windows（powershell）  
把**命令**交给系统  
terminal（最古老时是一个硬件）--屏幕+带键盘的物理设备，如今是一个软件  
默认情况下，**Ubuntu和大多数Linux发行版**是**bashshell**，还有zsh  
# setup and installing  
如果有Mac或者其他Linux发行版，则不需要额外操作。（作者在Mac里装了Ubuntu虚拟机）  
## WindowsSubsystem  
```wsl --install```  
默认是Ubuntu  