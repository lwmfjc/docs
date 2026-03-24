---
title: 09顶点缓冲区
description: 09顶点缓冲区
categories:
  - 学习
tags:
  - cherno
  - opengl
date: 2026-03-24T19:10:23+08:00
lastmod: 2026-03-24T19:10:23+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 总述

## 核心痛点：重复的顶点数据

- ==现状分析==：绘制一个矩形需要两个三角形（6 个顶点）。    
- ==资源浪费==：矩形只有 4 个角，使用 `glDrawArrays` 必须重复定义其中 2 个顶点（坐标、纹理、颜色等完全一致）。    
- ==影响==：随着模型复杂化，这种冗余会成倍消耗显存（VRAM）和带宽。 
## 解决方案：Index Buffer 原理

- ==定义==：索引缓冲区（IBO/EBO）存储的是指向顶点数组的==整数索引==。    
- ==逻辑==：
    1.  ==Vertex Buffer==：只存储 4 个唯一的顶点坐标。        
    2.  ==Index Buffer==：存储顺序（如 `0, 1, 2, 2, 3, 0`），告诉 GPU 如何连接这些点。        
- ==优势==：一个浮点数顶点属性通常 12-32 字节，而一个索引（`unsigned int` 或 `short`）仅需 4 或 2 字节。

## 编码实践：创建与绑定 IBO

- ==创建对象==：`glGenBuffers(1, &ibo);`    
- ==绑定目标==：必须指定为 ==`GL_ELEMENT_ARRAY_BUFFER`==。    
- ==填充数据==：

    ```cpp
    unsigned int indices[] = { 0, 1, 2, 2, 3, 0 };
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 6 * sizeof(unsigned int), indices, GL_STATIC_DRAW);
    ```
    
- ==注意==：索引必须是正整数，且建议使用 `unsigned int` 以保证最大兼容性。    

## 核心函数切换：glDrawElements

- ==替代方案==：不再使用 `glDrawArrays`，改为 `glDrawElements`。    
- ==参数详解==：    
    - `mode`: `GL_TRIANGLES` (绘制类型)        
    - `count`: `6` (索引的总个数，不是顶点个数)        
    - `type`: `GL_UNSIGNED_INT` (索引数据的类型，必须匹配)        
    - `indices`: `nullptr` (如果已绑定 IBO，则传空)        

## 调试与常见错误

- ==黑屏检查==：如果看不到图形，优先检查索引的==绕序==（Winding Order）。OpenGL 默认逆时针为正面。    
- ==类型误区==：严禁在索引中使用 `GL_FLOAT`。    
- ==解绑顺序==：在解绑 VAO 之前，不要解绑 `GL_ELEMENT_ARRAY_BUFFER`，否则索引关系会丢失。    

## 总结与性能建议

- ==结论==：Index Buffer 是现代 3D 渲染的标准配置。    
