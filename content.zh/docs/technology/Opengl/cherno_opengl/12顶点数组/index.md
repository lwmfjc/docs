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

- ==Compatibility Profile（兼容模式）==：*OpenGL 会默认帮你创建一个“隐藏的 VAO (ID为0)”。所以你之前不写 VAO 也能画出图*。    
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


# 没有VAO的情况下

```cpp
//循环前解绑
glUseProgram(program);

//===这里故意把他解绑了（假设他去绑定别的去了）===
glUseProgram(0);
glBindBuffer(GL_ARRAY_BUFFER, 0);
glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
glDisableVertexAttribArray(0);
glDisableVertexAttribArray(1);
//========================================
```

```cpp
//while循环中使用

// 游戏/渲染主循环
while (!glfwWindowShouldClose(window))
{
	// 清理屏幕颜色缓冲区
	glClear(GL_COLOR_BUFFER_BIT);

	//绘图前重新绑定
	glUseProgram(program);

	//glVertexAttribPointer更具体地指明了属性0、属性1，到绑定到当时的GL_ARRAY_BUFFER上的buffer去找，以及如何找。所以这里并不需要重新绑定GL_ARRAY_BUFFER
	glBindBuffer(GL_ARRAY_BUFFER, buffer);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);

	//========设置uniform========
	//==在绑定程序后，获取变量地址，然后设置变量==
	//问着色器，让着色器告诉CPU变量的位置
	unsigned int location = glGetUniformLocation(program, "u_Color");
	//不为1时会报错并且停止程序（当设置了变量但是着色器没
	//使用过时，OpenGL会在编译时删除那个变量）
	ASSERT(location != -1);

	if (r > 1.0f)
		increment = -0.05f;
	else if (r < 0.0f)
		increment = 0.05f;

	r += increment;

	//在u_Color的位置上设置数值
	glUniform4f(location, r, 0.3f, 0.0f, 1.0f);
	//========设置uniform========

	//重新启动属性
	glEnableVertexAttribArray(0);
	glEnableVertexAttribArray(1);

	glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nullptr);

	// 交换前后缓冲区以刷新画面
	glfwSwapBuffers(window);

	// 轮询并处理窗口事件（如键盘输入、关闭动作）
	glfwPollEvents();
}
```

# 使用了vao

```cpp
//生成顶点缓冲区之前（其他插槽绑定buffer之前）
	//使用vao记录
	unsigned int vao;
	glGenVertexArrays(1,&vao);
	glBindVertexArray(vao);//绑定vao
	
	unsigned int buffer;
	// 生成一个缓冲区 ID
	glGenBuffers(1, &buffer);
```

```cpp
//状态设置完之后解绑了
	glUseProgram(program);
	
	//===这里故意把他解绑了（假设他去绑定别的去了）===
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glUseProgram(0);
	glBindVertexArray(0);//解绑vao
	//element_array_buffer 和vertexAttribArray不能
	//在解绑vao之前处理，否则就记录进去了
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	glDisableVertexAttribArray(0);
	glDisableVertexAttribArray(1);
	//========================================
```

```cpp
//while循环中使用

// 游戏/渲染主循环
while (!glfwWindowShouldClose(window))
{
	// 清理屏幕颜色缓冲区
	glClear(GL_COLOR_BUFFER_BIT);

	//绘图前重新绑定
	glUseProgram(program);

	//必须先绑定program，因为vao不负责着色器程序的切换
	glBindVertexArray(vao);

	//========设置uniform========
	//==在绑定程序后，获取变量地址，然后设置变量==
	//问着色器，让着色器告诉CPU变量的位置
	unsigned int location = glGetUniformLocation(program, "u_Color");
	//不为1时会报错并且停止程序（当设置了变量但是着色器没
	//使用过时，OpenGL会在编译时删除那个变量）
	ASSERT(location != -1);

	if (r > 1.0f)
		increment = -0.05f;
	else if (r < 0.0f)
		increment = 0.05f;

	r += increment;

	//在u_Color的位置上设置数值
	glUniform4f(location, r, 0.3f, 0.0f, 1.0f);
	//========设置uniform========

	GLCall(glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nullptr));

	// 交换前后缓冲区以刷新画面
	glfwSwapBuffers(window);

	// 轮询并处理窗口事件（如键盘输入、关闭动作）
	glfwPollEvents();
}

//最后解绑vao
glBindVertexArray(0);

// 手动通知显卡驱动释放该程序占用的显存
glDeleteProgram(program);

```

# 商榷

在绘制多个不同对象的情况下更容易体现它的好处，这里问gemini给出了简单的例子

## 初始化

```cpp
// --- 物体 A：正方形 ---
unsigned int vaoSquare, vboSquare, iboSquare;
glGenVertexArrays(1, &vaoSquare);
glBindVertexArray(vaoSquare); // 开始录制 A 的状态

glGenBuffers(1, &vboSquare);
glBindBuffer(GL_ARRAY_BUFFER, vboSquare);
glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertices), squareVertices, GL_STATIC_DRAW);
glEnableVertexAttribArray(0);
glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(float), 0);

glGenBuffers(1, &iboSquare);
glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, iboSquare); // VAO 会记住这个 IBO
glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(squareIndices), squareIndices, GL_STATIC_DRAW);

glBindVertexArray(0); // 停止录制，存档 A

// --- 物体 B：三角形 ---
unsigned int vaoTriangle, vboTriangle, iboTriangle;
glGenVertexArrays(1, &vaoTriangle);
glBindVertexArray(vaoTriangle); // 开始录制 B 的状态

glGenBuffers(1, &vboTriangle);
glBindBuffer(GL_ARRAY_BUFFER, vboTriangle);
glBufferData(GL_ARRAY_BUFFER, sizeof(triVertices), triVertices, GL_STATIC_DRAW);
glEnableVertexAttribArray(0);
glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(float), 0);

glGenBuffers(1, &iboTriangle);
glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, iboTriangle); // VAO 会记住这个 IBO
glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(triIndices), triIndices, GL_STATIC_DRAW);

glBindVertexArray(0); // 停止录制，存档 B
```

## 使用

```cpp
while (!glfwWindowShouldClose(window))
{
    glClear(GL_COLOR_BUFFER_BIT);
    glUseProgram(program);

    // 1. 画正方形
    glBindVertexArray(vaoSquare); // 一键还原正方形的所有顶点状态
    glUniform4f(location, 1.0f, 0.0f, 0.0f, 1.0f); // 设为红色
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nullptr);

    // 2. 画三角形
    glBindVertexArray(vaoTriangle); // 一键还原三角形的所有顶点状态
    glUniform4f(location, 0.0f, 0.0f, 1.0f, 1.0f); // 设为蓝色
    glDrawElements(GL_TRIANGLES, 3, GL_UNSIGNED_INT, nullptr);

    glfwSwapBuffers(window);
    glfwPollEvents();
}
```
