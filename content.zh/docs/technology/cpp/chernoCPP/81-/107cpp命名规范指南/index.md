---
title: 107cpp命名规范指南
description: 107cpp命名规范指南
categories:
tags:
date: 2026-03-11T16:08:24+08:00
lastmod: 2026-03-11T16:08:24+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 核心观点：一致性胜过一切

Cherno 强调命名约定没有绝对的“正确”或“错误”，最重要的是==在整个项目（或公司/团队）中保持一致性==。

命名约定的目的是为了==让代码更具可读性，让你和他人能快速理解某个符号是类、变量、函数还是常量==。

# 类与结构体 (Classes & Structs)

大驼峰命名法 (PascalCase)： 建议类名首字母大写，例如 class Player 或 class Shader。

这样做可以一眼将类型名与变量名区分开。

# 变量命名 (Variables)

小驼峰命名法 (camelCase)： 局部变量通常首字母小写，例如 int score 或 float horizontalInput。

成员变量 (Member Variables)： 为了区分局部变量和类的成员变量，他推荐使用前缀（如 m_）。

例如：m_Name 或 m_Health。

优点： 在编写类成员函数时，通过输入 m_ 即可利用 IDE 的自动补全功能快速列出所有成员，并避免与函数参数重名。

# 函数与方法 (Functions & Methods)

大驼峰 vs 小驼峰： Cherno 个人更倾向于对函数使用大驼峰（PascalCase），例如 void SaveGame()。

他指出，如果变量用小驼峰、函数用大驼峰，可以非常清晰地分辨 Variable()（调用函数）和 variable（访问数据）。

# 静态变量与常量 (Statics & Constants)

静态变量： 类的静态成员有时使用 s_ 前缀，例如 s_Instance。

宏与全局常量： 习惯上使用全大写加下划线，例如 `#define MAX_BUFFER_SIZE 1024。`  

全局：g_  

常量：c_  

# 命名空间与文件 (Namespaces & Files)

命名空间： 通常使用小写字母。

文件名： 建议文件名与类名保持一致。如果类名是 Player，则文件命名为 Player.h 和 Player.cpp。

# 总结建议

不要纠结于某种特定的风格（如 Google 风格 vs LLVM 风格），选定一种并坚持下去。

==好的命名约定应该能让你在不看声明的情况下，仅通过名字就判断出变量的作用域和类型==。