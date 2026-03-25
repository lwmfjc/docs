---
title: 12顶点数组
description: 12顶点数组
categories:
  - 学习
tags:
  - cherno
  - opengl
date: 2026-03-25T13:30:24+08:00
lastmod: 2026-03-25T13:30:24+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
第 12 集是整个系列中非常关键的==架构转折点==。Cherno 在这一集深入讲解了 ==Vertex Array Object (VAO)==。

如果你之前觉得代码里那堆 `glVertexAttribPointer` 既乱又难记，那么这一集就是为你准备的“整理收纳柜”。

# 总述

## 为什么要用 VAO？（痛点分析）

- ==现状==：在核心模式（Core Profile）下，OpenGL 要求必须绑定一个 VAO 才能绘图。    
- ==问题==：如果你有多个模型（比如一个三角形、一个正方形），每个模型都有自己的 `VBO`、`IBO` 和复杂的 `VertexBufferLayout`（顶点布局）。    
- ==后果==：每次切换模型画图，你都要重新写一遍 `glBindBuffer`、`glEnableVertexAttribArray` 和 `glVertexAttribPointer`。这太啰嗦了！
## VAO 的本质：状态的“存档”

- ==定义==：VAO 就像是一个==配置记录仪==。它不会存储实际的顶点坐标数据，但它会==记住==：
    
    1.  哪个 ==VBO== 与它绑定了。        
    2.  ==属性布局==（多少个 float、偏移量是多少、是否归一化）。
        
- ==优势==：一旦你设置好了 VAO，下次画这个模型时，只需要一行 `glBindVertexArray(vaoID)`，所有的 VBO 绑定和属性设置就会==瞬间还原==。
    

## 兼容性大坑：Core vs Compatibility

- ==Compatibility Profile（兼容模式）==：OpenGL 会默认帮你创建一个“隐藏的 VAO (ID为0)”。所以你之前不写 VAO 也能画出图。
    
- ==Core Profile（核心模式）==：必须显式地 `glGenVertexArrays`。如果不绑定 VAO 就直接调用 `glVertexAttribPointer`，程序会直接崩溃或报错。
    
- ==Cherno 的建议==：永远手动创建 VAO，这样你的代码在任何显卡驱动和模式下都是健壮的。
    

## 编码实践：如何创建 VAO

- ==标准流程==：
    
    1.  `unsigned int vao; glGenVertexArrays(1, &vao);`
        
    2.  `glBindVertexArray(vao);`
        
    3.  `glBindBuffer(GL_ARRAY_BUFFER, vbo);`
        
    4.  `glVertexAttribPointer(...);`
        
    5.  `glEnableVertexAttribArray(0);`
        
- ==注意==：顺序很重要！必须先绑定 VAO，再去绑定 VBO 和设置属性，这样 VAO 才能“录制”下这些操作。
    

## 渲染循环的简化

- ==旧写法==：每帧都要重复绑定 VBO 和设置 Pointer。
    
- ==新写法==：
    
    ```scss
    // 渲染时
    glBindVertexArray(vao); // 这一行顶过去三四行
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo); // IBO 比较特殊，通常也需要手动再绑一下
    glDrawElements(...);
    ```
    

___

## 💡 博客总结（给读者的金句）

|  特性  | Vertex Buffer (VBO) |   Vertex Array (VAO)    |
|------|---------------------|-------------------------|
|  ==角色==  |     搬运工（存原始数据）      |       经理（管配置和状态）        |
| ==存储内容== |  `float`, `int` 等坐标数据   | `Pointer` 设置和 `Buffer` 绑定关系 |
| ==调用频率== |     初始化时填充一次数据      |     每次切换不同物体绘制时切换一次     |

___

## ⚠️ 你在写博客时可以特别强调的一点：

==IBO (Index Buffer) 与 VAO 的微妙关系==： 在某些 OpenGL 实现中，VAO 会记住 `GL_ELEMENT_ARRAY_BUFFER` 的绑定，但在另一些实现中可能不会。为了保险起见，Cherno 建议在每次 Draw 之前显式地绑定一下 IBO。

==既然你已经理解了 VAO 是如何简化状态切换的，我们要不要动手写一个 `VertexArray` 类？== 这样我们可以把那些繁琐的 `gl` 开头的函数封装成 `va.AddBuffer(vbo, layout);`。想看看这个类的结构怎么写吗？