---
title: 22关于ImGui
description: 22关于ImGui
categories:
  - 学习
tags:
  - cherno
  - opengl
date: 2026-04-28T22:49:11+08:00
lastmod: 2026-04-28T22:49:11+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
第 22 集是 Cherno 系列中非常爽的一集，因为它让你告别了“硬编码”坐标的痛苦，转而使用==可视化 UI== 来直接操控显卡里的数据。

按==程序生命周期的时间线==，我们可以把 ImGui 的集成与运行分为以下阶段：


# 1. 初始化阶段：建立连接

在窗口创建（GLFW）之后，但在渲染循环开始前，你需要为 ImGui 搭建好舞台。

- ==动作==：`ImGui::CreateContext()`。    
- ==绑定==：调用 `ImGui_ImplGlfw_InitForOpenGL` 和 `ImGui_ImplOpenGL3_Init`。   
- ==目的==：让 ImGui 知道两件事：它该去哪个窗口捕获鼠标/键盘（GLFW），以及它该用哪个版本的驱动来画出自己的 UI（OpenGL）。


# 2. 渲染循环内：新帧准备

在 `while(!glfwWindowShouldClose)` 循环的最开始。

- ==动作==：`ImGui_ImplOpenGL3_NewFrame()` 和 `ImGui_ImplGlfw_NewFrame()`。    
- ==目的==：告诉 ImGui：“现在是新的一帧了，请清空上一帧的状态，开始记录我接下来的 UI 指令。”


# 3. UI 逻辑阶段：定义面板

这是你在第 22 集花最多时间写代码的地方。

- ==动作==：`ImGui::Begin("Debug Panel")` `ImGui::SliderFloat3(...)` `ImGui::End()`。    
- ==核心逻辑==：
    
    - 你定义了一个滑动条，并把它==绑定==到你 C++ 中的变量（比如 `translationA`）。        
    - ==关键点==：ImGui 并不直接操作显卡，它只是==修改了 CPU 里的变量值==。
    


# 4. 矩阵更新阶段：重新翻译 (MVP)

这是将 UI 和 3D 画面联动的关键点。

- ==动作==：利用刚才被 ImGui 修改的 `translationA`，重新计算 `model` 矩阵。
- ==计算==：`mvp = proj * view * model;`。    
- ==目的==：UI 改变了数值 数值改变了矩阵 矩阵改变了顶点位置。


# 5. 提交渲染阶段：绘制 UI

在你的物体（如 Logo）渲染完毕之后。

- ==动作==：`ImGui::Render()` `ImGui_ImplOpenGL3_RenderDrawData(...)`。
- ==顺序==：必须先画你的 Logo，再画 ImGui。否则，UI 可能会被你的 3D 物体遮挡住（因为 ImGui 也是一组顶点和索引）。    
- ==结果==：ImGui 把自己生成的三角形数据通过 `glDrawElements` 传给 GPU，叠放在画面最上层。


# 💡 核心总结：22 集的思维跃迁

|  维度  |      集成前       |         集成后 (第 22 集)         |
|------|----------------|------------------------------|
| ==调试方式== | 修改代码 编译 运行 观察  |        ==实时拖动滑动条 瞬间看到反馈==        |
| ==变量控制== | 硬编码在 `main` 函数里  |      暴露在 UI 面板上，支持动态交互       |
| ==渲染顺序== | 只有物体的 `DrawCall` | ==物体 DrawCall + ImGui DrawCall== |


# 🛠️ 这一集的“醍醐灌顶”

你在这一集最深刻的体验应该是：==当你拖动滑动条，那个矩形（Logo）在屏幕上丝滑移动的时候。==

本质上，ImGui 在这一帧修改了 `translationA.x`，而下一行代码立即用新的 `x` 算出了新的 `MVP` 传给 Shader。因为每秒钟这个过程发生 60 次（60 FPS），所以你看到的移动才是连贯的。

==你现在是不是已经成功把两个 Logo 摆在不同的位置了？这就是通过同一个 `Shader` 和 `Vertex Array`，但每画一个物体前更新一次不同的 `u_MVP` 来实现的。==