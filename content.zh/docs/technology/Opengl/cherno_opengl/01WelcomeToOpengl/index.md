---
title: 01WelcomeToOpengl
description: 01WelcomeToOpengl
categories:
  - 学习
tags:
  - opengl
  - cherno
date: 2026-03-21T19:43:45+08:00
lastmod: 2026-03-21T19:43:45+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 大纲

```shell
[16:04] 01-欢迎来到 OpenGL-Welcome to OpenGL
[22:03] 02-在 C++ 中设置 OpenGL 并创建窗口-Setting up OpenGL and Creating a Window in C++
[18:21] 03-在 C++ 中使用现代 OpenGL-Using Modern OpenGL in C++
[20:06] 04-顶点缓冲区与在 OpenGL 中绘制三角形-Vertex Buffers and Drawing a Triangle in OpenGL
[18:54] 05-OpenGL 中的顶点属性与布局-Vertex Attributes and Layouts in OpenGL
[17:37] 06-OpenGL 中的着色器工作原理-How Shaders Work in OpenGL
[28:21] 07-在 OpenGL 中编写着色器-Writing a Shader in OpenGL
[21:15] 08-我是如何处理 OpenGL 中的着色器的-How I Deal with Shaders in OpenGL
[16:54] 09-OpenGL 中的索引缓冲区-Index Buffers in OpenGL
[23:42] 10-处理 OpenGL 中的错误-Dealing with Errors in OpenGL
[11:27] 11-OpenGL 中的 Uniform 变量-Uniforms in OpenGL
[21:50] 12-OpenGL 中的顶点数组-Vertex Arrays in OpenGL
[26:46] 13-将 OpenGL 抽象为类-Abstracting OpenGL into Classes
[30:07] 14-OpenGL 中的缓冲区布局抽象-Buffer Layout Abstraction in OpenGL
[21:56] 15-OpenGL 中的着色器抽象-Shader Abstraction in OpenGL
[14:43] 16-在 OpenGL 中编写基础渲染器-Writing a Basic Renderer in OpenGL
[31:44] 17-OpenGL 中的纹理-Textures in OpenGL
[12:37] 18-OpenGL 中的混合-Blending in OpenGL
[18:07] 19-OpenGL 中的数学-Maths in OpenGL
[20:10] 20-OpenGL 中的投影矩阵-Projection Matrices in OpenGL
[15:53] 21-OpenGL 中的 MVP 矩阵-Model View Projection Matrices in OpenGL
[14:36] 22-在 OpenGL 中使用 ImGui-ImGui in OpenGL
[12:21] 23-在 OpenGL 中渲染多个物体-Rendering Multiple Objects in OpenGL
[16:52] 24-为 OpenGL 设置测试框架-Setting up a Test Framework for OpenGL
[22:46] 25-在 OpenGL 中创建测试-Creating Tests in OpenGL
[28:13] 26-在 OpenGL 中进行纹理测试-Creating a Texture Test in OpenGL
[11:37] 27-如何让你的 UNIFORMS 更快-How to make your UNIFORMS FASTER in OpenGL
[12:25] 28-批量渲染：简介-Batch Rendering - An Introduction
[09:15] 29-批量渲染：颜色-Batch Rendering - Colors
[15:51] 30-批量渲染：纹理-Batch Rendering - Textures
[23:17] 31-批量渲染：动态几何体-Batch Rendering - Dynamic Geometry
```

# 总结
-  课程初衷与背景
    - 作者介绍了为什么要制作这个系列：市面上很多教程只教“怎么做”，而不教“为什么”。   
    - 本系列的目标是不仅让你写出代码，还要让你理解 OpenGL 的底层工作原理及其与 GPU 的交互逻辑。   
- 什么是 OpenGL？    
    - ==核心定义==：OpenGL 本质上是一个==规范（Specification）== ~~接口，API~~ ，而不是一个具体的库。它==规定了函数应该如何命名、参数是什么以及预期的行为==。 ~~允许我们实际访问我们的GPU，GraphicsProcessingUnit，图形处理单元。OpenGL是其中之一的接口，还有Direct3D，Vulkan，Metal等~~ 
    - ==实现者==：*具体的实现通常由显卡厂商（NVIDIA, AMD, Intel）编写在驱动程序中*。
    - 跨平台，Windows、Linux、Mac、Android、IOS
    - ==状态机（State Machine）==：初步引入 ==OpenGL 是一个状态机==的概念，你==设置好状态（如颜色、缓冲区），然后发出指令进行渲染==。
- 现代 OpenGL vs 传统 OpenGL 
    - ==Legacy OpenGL (固定管线)==：简单但不够灵活，很多功能已经废弃（如 `glBegin`, `glEnd`）。   
    - ==Modern OpenGL (可编程管线)==：通过 ==着色器 (Shaders)== 控制渲染过程。虽然代码量显著增加，但提供了==极大的灵活性和性能优化==空间。  
    - 本系列将专注于 ==Modern OpenGL (版本 3.3 及以上)==。   
- 学习 OpenGL 的难点与心态   
    - 强调了学习曲线：初期需要写==大量的“模板代码”（Boilerplate code）==才能在屏幕上画出一个简单的三角形。   
    - ==图形管线 (Graphics Pipeline)==：解释了==数据如何从 CPU 传输到 GPU==，并==经过顶点处理、光栅化最终变成像素==的过程。   
- 开发环境与工具链预告   
    - 虽然是跨平台的，但本系列主要在 Windows 下使用 ==Visual Studio== 演示。   
    - 提到后续会使用的关键第三方库：==GLFW==（窗口管理）和 ==GLEW/GLAD==（访问 OpenGL 扩展函数）。   
- 总结与后续计划
    - 鼓励初学者不要被前几集的复杂配置和概念吓退。   
    - 下一集将正式进入 C++ 环境配置，动手创建第一个窗口。