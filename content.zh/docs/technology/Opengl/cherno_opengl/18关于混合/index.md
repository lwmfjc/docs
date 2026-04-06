---
title: 18关于混合
description: 18关于混合
categories:
  - 学习
tags:
  - cherno
  - opengl
date: 2026-04-06T23:21:41+08:00
lastmod: 2026-04-06T23:21:41+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
这一集是关于如何处理==透明度（Alpha Channel）==的关键。当两个物体重叠时，GPU 如何决定最终像素的颜色？这就是“混合”要解决的问题。

# 问题的引入：为什么我的图片有“黑边”？

在加载带透明通道的 `.png` 纹理时，如果不开启混合，透明区域通常会显示为==纯黑色==或==纯白色==。这是因为：

- 默认情况下，OpenGL 只是简单地用新像素 ==覆盖（Overwrite）==旧像素。    
- 即使你的纹理有 Alpha 值（例如 ），如果不告诉 OpenGL 如何处理它，它依然会把这个“透明”的像素颜色画上去。

# 开启混合 (Enable Blending)

OpenGL 是一个状态机，混合功能默认是关闭的。你必须手动开启：

```scss
GLCall(glEnable(GL_BLEND));
```

开启后，你需要定义==混合函数（Blend Function）==，即告诉 OpenGL：“拿新颜色（源）和旧颜色（目标）怎么算？”

# 核心公式：混合方程式

这是这一集最硬核的数学部分。OpenGL 计算最终像素颜色的公式如下：

- ==(Source Color)==：即将画上去的颜色（来自 Fragment Shader）。    
- ==(Source Factor)==：源颜色的权重。    
- ==(Destination Color)==：已经在颜色缓冲区里的颜色（背景色）。    
- ==(Destination Factor)==：目标颜色的权重。    

# 最常用的配置：实现透明效果

为了实现自然的透明（即：新物体的透明度越高，透出的背景越多），Cherno 给出了最经典的配置方案：

```scss
GLCall(glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA));
```

==逻辑拆解：==

1. 源颜色的权重是它自己的 Alpha 值。    
2. 背景颜色的权重是 。    

==举个例子：== 如果你画一个 Alpha 为 （ 不透明）的红色方块在黑色背景上：

- 最终颜色 = 。
- 结果就是一种半透明的暗红色。
    

# 混合方程式的进阶设置

除了 `glBlendFunc` 定义权重，还可以通过 `glBlendEquation` 定义中间的符号：

- ==`GL_FUNC_ADD`==：相加（默认，最常用）。    
- ==`GL_FUNC_SUBTRACT`==：相减。    
- ==`GL_MIN / GL_MAX`==：取两者的最小值或最大值。
    

# 容易踩的坑：深度测试与混合

虽然这一集 Cherno 侧重于 2D，但你需要记住一个原则：

- ==顺序很重要==：在 3D 环境中，必须==先画不透明物体，再按从远到近的顺序画透明物体==。否则，由于深度缓冲区（Depth Buffer）的存在，远处的透明物体可能无法正确透过近处的透明物体显示。