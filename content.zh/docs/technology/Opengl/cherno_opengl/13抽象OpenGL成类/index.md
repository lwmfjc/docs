---
title: 13抽象OpenGL成类
description: 13抽象OpenGL成类
categories:
  - 学习
tags:
  - opengl
  - cherno
date: 2026-03-25T18:01:15+08:00
lastmod: 2026-03-25T18:01:15+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
将零散的 OpenGL 原生 API 封装成 ==C++ 类==。这不仅是为了让 `main` 函数变干净，更是为了构建一个可复用的==渲染引擎底层==。

# 概述

## 为什么要抽象？（工程思维）

- ==现状==：`main.cpp` 已经膨胀到几百行，充斥着大量的 `glGen`、`glBind`。
- ==目标==：我们不希望在业务逻辑里看到底层的 `unsigned int ID`。我们要操作的是“对象”（Object）。    
- ==类划分预想==：    
    - ==VertexBuffer==：管理 `GL_ARRAY_BUFFER`。        
    - ==IndexBuffer==：管理 `GL_ELEMENT_ARRAY_BUFFER`。        
    - ==VertexArray==：管理属性布局（Layout）和 VAO。
   
## 封装 VertexBuffer 类

这是最基础的一步。将 VBO 的创建、绑定和销毁封装起来。

- ==构造函数==：接收数据和大小，直接 `glGen` 并 `glBufferData`。    
- ==析构函数==：调用 `glDeleteBuffers`，实现 ==RAII==（资源获取即初始化）机制，防止内存泄漏。    
- ==关键方法==：`Bind()` 和 `Unbind()`。
    
```cpp
// 你的博客可以展示这个极简结构
class VertexBuffer {
private:
    unsigned int m_RendererID; // Cherno 喜欢用 m_ 前缀表示成员变量
public:
    VertexBuffer(const void* data, unsigned int size);
    ~VertexBuffer();
    void Bind() const;
    void Unbind() const;
};
```

## 封装 IndexBuffer 类

与 VertexBuffer 几乎一模一样，但有两点不同：

1.  ==目标类型==：固定为 `GL_ELEMENT_ARRAY_BUFFER`。    
2.  ==计数器==：增加一个 `m_Count` 变量，记录有多少个索引（Indices），因为 `glDrawElements` 绘图时需要这个数字。

## 封装 Shader 预告与 VertexArray 的难题

Cherno 提到了最难封装的部分：==VertexArray (VAO)==。

- ==难点==：VAO 不仅仅是绑定，它还得知道 VBO 里的数据长什么样（Layout）。    
- ==设计模式==：引入了一个中间结构 ==`VertexBufferLayout`==。    
    - 它像一个“购物清单”，记录了：这里有 2 个 float（位置），那里有 2 个 float（纹理坐标）。        
    - `VertexArray::AddBuffer` 方法会读取这个清单，循环调用 `glVertexAttribPointer`。

## 最终效果：main 函数的瘦身

封装完成后，原本几十行的初始化代码变成了：

```scss
VertexBuffer vb(positions, 4 * 2 * sizeof(float));
VertexBufferLayout layout;
layout.Push<float>(2); // 压入位置属性
va.AddBuffer(vb, layout); // VAO 自动处理绑定和属性设置

IndexBuffer ib(indices, 6);
```

==渲染循环里只需要：==

```scss
shader.Bind();
va.Bind();
ib.Bind();
GLCall(glDrawElements(GL_TRIANGLES, ib.GetCount(), GL_UNSIGNED_INT, nullptr));
```

## 💡 博客总结（给读者的金句）

- ==RAII 思想==：对象创建时，显存分配；对象销毁时，显存释放。    
- ==解耦==：`main` 函数不再关心 `unsigned int ID` 是多少，只关心 `vb`、`ib` 这些对象。
- ==m\_RendererID==：这是 Cherno 的标志性命名方式。`RendererID` 强调这个 ID 是由 OpenGL 驱动程序（渲染器）生成的。
## ⚠️ 写博客时的特别提醒：

在第 12 集的类封装里，一定要提到 ==`const` 关键字== 的使用。Cherno 非常强调 `Bind()` 和 `Unbind()` 函数应该是 `const` 的，因为它们不修改类成员变量的值，只是改变 OpenGL 的状态。这是专业 C++ 程序员的修养。

