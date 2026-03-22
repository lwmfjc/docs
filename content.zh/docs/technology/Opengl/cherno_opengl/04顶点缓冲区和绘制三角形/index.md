---
title: 04顶点缓冲区和绘制三角形
description: 04顶点缓冲区和绘制三角形
categories:
  - 学习
tags:
  - opengl
  - cherno
date: 2026-03-22T16:24:13+08:00
lastmod: 2026-03-22T16:24:13+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 总述

这一集（时长 20:06）标志着你正式从“配置环境”跨越到了“图形编程”。这里讲解了现代 OpenGL 的灵魂：==如何把 CPU 内存里的数据塞进 GPU 显存里==。

- ==什么是顶点缓冲区 (Vertex Buffer / VBO)？==    
    - ==核心定义==：它本质上是 GPU 显存中的一块内存区域，用于存储顶点的各种数据（坐标、颜色等）。        
    - ==为什么要用它？==：CPU 到 GPU 的总线传输相对较慢。我们希望一次性把大量数据推送到显存，然后让 GPU 在内部高速读取，而不是每帧都由 CPU “手把手”教 GPU 怎么画。
        
- ==定义顶点数据==    
    - 在 C++ 中创建一个浮点数数组 `float positions[6]`，存入三个顶点的 坐标。        
    - 注意：此时这些数据还在 ==RAM（内存）== 中，GPU 还看不见它们。
        
- ==生成缓冲区 ID (`glGenBuffers`)==    
    - OpenGL 是基于状态机的。我们不直接操作对象指针，而是操作 ==ID (unsigned int)==。       
    - 调用 `glGenBuffers(1, &buffer)`：向 OpenGL 申请一个 ID，代表我们要创建的一个缓冲区。
        
- ==绑定缓冲区 (`glBindBuffer`)==    
    - 这是初学者最容易晕的地方。OpenGL 像是一个只有一个插槽的播放器。      
    - 调用 `glBindBuffer(GL_ARRAY_BUFFER, buffer)`：告诉 OpenGL，“从现在起，所有关于 `GL_ARRAY_BUFFER` 的操作，都请针对我刚刚申请的这个 `buffer` 进行”。
        
- ==填充数据 (`glBufferData`)==    
    - 这是真正发生“搬运”动作的代码。        
    - 参数解释：        
        1.  目标：`GL_ARRAY_BUFFER`。            
        2.  大小：`6 * sizeof(float)`。            
        3.  数据指针：`positions`。            
        4.  使用方式：`GL_STATIC_DRAW`（告诉显卡：这些数据我画一次后基本不动了，请优化存储）。
            
- ==为什么屏幕上还是没东西？==    
    - Cherno 解释了：虽然数据到了显存，但 GPU 不知道这堆二进制数据是什么。是坐标？是颜色？还是贴图坐标？
    - 引出下一集的主题：==顶点属性布局 (Vertex Attributes)==。
- ==临时方案：使用 Legacy Shader==
    - 因为还没教怎么写着色器，Cherno 演示了一个简单的 `glDrawArrays` 调用。
    - ==注意==：在现代 OpenGL 中，如果没有着色器，通常什么都画不出来。但他为了演示效果，先让大家看到一个三角形的轮廓。
- ==总结与警告==
    - 强调了 `unsigned int` 在 OpenGL 中的重要性。
    - ==预告==：数据进了显存只是第一步，下一集将解决“如何告诉 GPU 怎么解释这些数据”的问题。
        
## 核心操作流程图（必须记住的“三部曲”）

1.  ==Gen (申请)==: `glGenBuffers` — 找 OpenGL 要个号。
2.  ==Bind (挂载)==: `glBindBuffer` — 把这个号挂到当前操作位上。
3.  ==Data (填充)==: `glBufferData` — 把内存里的数组塞进这个号对应的显存里。

==下一步建议：== 第 04 集只是把“原材料”送进了工厂。第 05 集的 ==Vertex Attributes== 才是真正的“加工说明书”，那是让你的代码从黑屏变成彩色三角形的关键。  


# 教程

- 原理：需要定义一些数据来表示三角形，然后把它放到GPU的VRAM（显存），然后发出DrawCall指令（绘制） ~~指令：你的显存里有一堆指定，读取它，然后把它绘制在屏幕上。（还要告诉先开如何读取和解释这些数据，如何把它放到屏幕上）~~ 。  还要对GPU编程（着色器，运行在GPU上的程序）  
- OpenGL具体的操作就是一个状态机，我们要做的是设置一系列的状态，然后当你说让它做什么事时，它根据之前传的状态进行处理。  
	- 比如，我想让你选择这个缓冲区，用这个着色器，绘制个三角形，绘制在哪里。
- 推荐一个网址 doc.opengl  
- 目前还没有写着色器，所以不会绘制任何东西
# 代码

```cpp
#ifdef LY_EP04
#include <iostream>
#include <GL/glew.h>
#include <GLFW/glfw3.h>

int main(void)
{
#pragma region 一些初始化
	GLFWwindow* window;
	/* Initialize the library */
	if (!glfwInit())
		return -1;
	/* Create a windowed mode window and its OpenGL context */
	window = glfwCreateWindow(640, 480, "Hello World", NULL, NULL);
	if (!window)
	{
		glfwTerminate();
		return -1;
	}
	/* Make the window's context current */
	glfwMakeContextCurrent(window);
	//先有窗口和上下文，加载器才能工作
	if (glewInit() != GLEW_OK)
	{
		std::cout << "Error!" << std::endl;
	}
#pragma endregion


	float positions[6] = {
		-0.5f, -0.5,
		0.0f, 0.5f,
		0.5f, -0.5f
	};

	//用来存储生成的顶点缓冲区id
	unsigned int buffer;
	//定义顶点缓冲区，把生成的缓冲区id(唯一的id)存储到给定地址,
	//之后想使用这个缓冲区对象的时候，传这个id即可
	glGenBuffers(1, &buffer);
	// 告诉 OpenGL：把 ID 为 buffer 的这个缓冲区，
	// “插”进 GL_ARRAY_BUFFER 这个槽位里。
	// 接下来所有针对 GL_ARRAY_BUFFER 的操作（如填
	// 充数据、设置格式），都会作用在这个特定的 buffer 上。
	glBindBuffer(GL_ARRAY_BUFFER, buffer);
	//对这个槽位操作：填充数据
	//你告诉显卡：“我打算怎么用这块数据，多久改一次？”显卡会根据你的回答，决定把这块数据放在显存的哪个位置（是读写最快的地方，还是稍微慢一点但方便修改的地方）
	//STREAM: 数据几乎每一帧都要修改（例如：每帧都在变的粒子效果）。STATIC: 数据只设置一次，之后几乎不动（例如：静态的地形、房屋模型）。DYNAMIC : 数据会频繁修改，但可能不像每帧那么夸张
	//DRAW: 数据由 CPU 写入，供 GPU 读取用于画图（这是 99% 的情况）。READ: 数据由 GPU 写入，供 CPU 读取（例如：回传渲染结果）。COPY : 数据由 GPU 写入，供 GPU 以后自己读取。
	glBufferData(GL_ARRAY_BUFFER, 6 * sizeof(float),
		positions, GL_STATIC_DRAW);
	//接下来需要告诉GPU，我给的这几个字节的数据该如何读

	/* Loop until the user closes the window */
	//在while中添加代码
	while (!glfwWindowShouldClose(window))
	{
		/* Render here */
		glClear(GL_COLOR_BUFFER_BIT);

		//给缓冲区发出指令，1：指定绘制的图形
		//2：指定偏移量（指定数组中起始位置，可以非零）
		//3：渲染的顶点的数量，而不是画多少个“形状”
		//这里没有指定任何东西，但是由于OpenGL是一个状态机，
		//线性读取：从当前绑定在 GL_ARRAY_BUFFER 上的缓冲区中，从第 0 个顶点开始，顺次读取 3 个顶点进行渲染。
		//所以，drawArrays之前GL_ARRAY_BUFFER一定要绑定着
		//某一个缓冲区
		glDrawArrays(GL_TRIANGLES, 0, 3);

		//有个参数填写要绘制的顶点数量
		//另一个参数指定渲染的顶点顺序
		//glDrawElements(...);

		/* Swap front and back buffers */
		glfwSwapBuffers(window);

		/* Poll for and process events */
		glfwPollEvents();
	}

	glfwTerminate();
	return 0;
}

#endif
```

