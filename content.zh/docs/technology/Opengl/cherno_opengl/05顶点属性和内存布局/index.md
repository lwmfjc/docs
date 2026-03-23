---
title: 05顶点属性和内存布局
description: 05顶点属性和内存布局
categories:
  - 学习
tags:
  - cherno
  - opengl
date: 2026-03-22T18:53:01+08:00
lastmod: 2026-03-22T18:53:01+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
在第 04 集里你把数据塞进了显存，但 GPU 面对那一串二进制数字是“瞎”的。这一集的核心就是==给数据贴标签==，告诉 GPU 如何读取这些坐标。

-   ==问题的引入：为什么屏幕还是黑的？==    
    -   数据（Positions）已经在 VRAM 里了，但 GPU 不知道这堆 `float` 代表什么。        
    -   是一组 坐标？还是 颜色？或者是贴图坐标？        
    -   我们需要一份“说明书”来定义数据的==布局 (Layout)==。        
-   ==核心函数：`glVertexAttribPointer` 详解==    
    -   这是 OpenGL 中参数最复杂的函数，Cherno 逐一拆解了这 6 个参数： 
        1.  ==index==: 属性的索引（例如：0号属性给位置，1号属性给颜色，2号属性给纹理）。 
        2.  ==size==: 每个属性包含几个分量（位置是3，纹理是2）。
        3.  ==type==: 数据类型（`GL_FLOAT`）。
        4.  ==normalized==: 是否归一化（通常选 `GL_FALSE`）。
        5.  ==stride (步长)==: ==最关键参数==。从*某个属性的起始点*到*下一个属性起始点*的字节数。（这里第一组到第二组，位置index从0->5，纹理index从3->8，这里是`5 * sizeof(float)`）
        6.  ==pointer (偏移量)==: 在单个顶点数据块内，该属性距离(这个块的)起始位置的字节偏移。
```cpp
//这里举一个特殊的例子，LearnOpenGL中的
float vertices[] = {
-0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
 0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
 0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
 };
 
//配置位置属性
glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
glEnableVertexAttribArray(0); 

//配置纹理属性
glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3 * sizeof(float)));
//第二个2，和上面第一个参数，也就是 vs文件中的location一致，
//表示要启用 2 号属性（对应纹理）
glEnableVertexAttribArray(2);
```
-   ==内存布局的可视化演示==    
    -   Cherno 使用画图工具展示了数据在内存中是如何排列的。        
    -   如果每个顶点只有 2 个 `float` 坐标，那么 ==Stride== 就是 `2 * sizeof(float)`。        
    -   如果以后加上纹理坐标（又多 2 个 `float`），==Stride== 就会变成 `4 * sizeof(float)`。        
-   ==启用顶点属性 (`glEnableVertexAttribArray`)==    
    -   仅仅定义了“说明书”还不够，必须通过这个函数==手动开启对应的属性索引==（本例中是 0）。        
    -   默认情况下，为了性能，所有属性槽位都是关闭的。        
-   ==链接缓冲区与属性==    
    -   强调了一个隐式逻辑：`glVertexAttribPointer` 关联的是==当前绑定在 `GL_ARRAY_BUFFER` 上的那个 ID==。        
    -   这再次体现了 OpenGL “状态机”的特性。        
-   ==总结与运行结果==    
    -   加上这两行关键代码后，配合默认或简单的着色器，屏幕上终于能画出三角形的轮廓了。        
    -   预告：下一集将进入 ==Shader (着色器)== 的世界，那是真正赋予图形灵魂的地方。
-  核心操作流程（接续你的代码）

在你的 `glBufferData` 之后，必须补充这两行，否则 `glDrawArrays` 找不到数据：

```scss
// 定义布局：0号属性，2个分量(x,y)，浮点型，不需要归一化，步长是2个float的长度，偏移量为0
glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 2, 0);
// 开启 0 号属性
glEnableVertexAttribArray(0);
```

==下一步建议：== 你现在的代码已经补齐了“数据”和“布局”。==第 06 集==将讲解 ==Shader（着色器）== 的工作原理。那是跑在 GPU 上的小程序，负责处理顶点的位置和像素的颜色。

# 论述

- OpenGL管道的工作原理是我们为GPU提供数据，==在GPU上存储一些内容==，它==包含了我们想要绘制的所有数据==，然后我们*使用一个着色器*，是一个*在显卡上执行的程序来读数据*，并且完全显示在屏幕上  
- 通常我们画几何图形的方式，是使用一个叫顶点缓冲区的东西，这基本上是==存储在GPU上的内存缓冲区==。所以当对着色器编程时，实际上，是==从读取顶点缓冲区开始==的，它==需要知道缓冲区的布局==，这个缓冲区实际上包含的是一堆浮点数，他们指定了每个顶点的位置坐标 ~~还有颜色、或者纹理坐标~~ 。所以我们一定要告诉GPU内存中有什么，又是如何布局 ~~通过glVertexAttribPointer函数~~ 的
	- 比如前12个字节是3个浮点数，这是位置；之后8个字节是纹理坐标2个浮点数
- 着色器端也需要接收在CPU端定义的layout
- 顶点是几何图形上的一个点，但是在视觉上我们通过可以==通过其中的位置坐标给它定位==。顶点不止包括位置，还有颜色、条纹等

# 代码

![](img/ly-20260323162130632.png)  


```cpp
#ifdef LY_EP05
#include <iostream>
#include <GL/glew.h>
#include <GLFW/glfw3.h>

int main(void)
{
#pragma region 一些初始化
	GLFWwindow* window;
	// 初始化 GLFW 库，失败则退出
	if (!glfwInit())
		return -1;

	// 创建窗口对象
	window = glfwCreateWindow(640, 480, "Hello World", NULL, NULL);
	if (!window)
	{
		// 创建失败则清理并退出
		glfwTerminate();
		return -1;
	}

	// 将当前窗口的上下文设置为 OpenGL 渲染的目标
	glfwMakeContextCurrent(window);

	// 初始化 GLEW 以加载 OpenGL 函数指针，需在有上下文后执行
	if (glewInit() != GLEW_OK)
	{
		std::cout << "Error!" << std::endl;
	}
#pragma endregion

	// 定义三角形的顶点坐标（CPU 内存）
	float positions[25] = {
		-0.5f, -0.5,0.0f,0.3f,
		0.0f, 0.5f,0.0f,0.3f,
		0.5f, -0.5f,0.0f,0.3f,
		1.0f, 0.5f,0.0f,0.3f,
		0.0f, 0.5f,0.0f,0.3f,
	};

	unsigned int buffer;
	// 生成一个缓冲区 ID
	glGenBuffers(1, &buffer);
	// 绑定该 ID 到顶点缓冲区插槽
	glBindBuffer(GL_ARRAY_BUFFER, buffer);
	// 将顶点数据从 CPU 内存拷贝到 GPU 显存，设为静态读取模式
	glBufferData(GL_ARRAY_BUFFER, 25 * sizeof(float),
		positions, GL_STATIC_DRAW);


	// 启用索引为 0 的(顶点)属性
	// 默认情况下，所有顶点属性都是禁用的，必须手动“合上电闸”才能让 GPU 读取该属性。
	glEnableVertexAttribArray(0);

	//参数1-index：顶点的哪个属性[有位置、颜色、纹理等]（和在着色器程序里指定的索引一致），设置完后，当使用着色器程序从显卡读取位置时，就能从缓冲区，简单的读取并使用这些属性
	//参数2-size：每个属性是几个分量的向量，即占用了几个数值
	//参数3-type：提供的数据类型
	//参数4normalized：是否归一化，可以让cpu帮你做（那就是true），或者弄好传给它。（比如
	//把0-255映射成0-1
	//参数5stride：从*当前顶点的属性的起始点*到*下一个顶点的同属性起始点*的字节数
	//参数6pointer：在单个顶点数据块内，该属性距离(这个块的)起始位置的字节偏移。可以使用宏简化 
	//1. 打标签：它把当前 GL_ARRAY_BUFFER 里的数据流，贴上了“0号”的标签。2. 定规则：它告诉 GPU，当你（Shader）想要 location = 0 的数据时，请按照“每 2 个 float 为一组”的规则去缓存里抓取。
	glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 4, (const void*)0);


	glEnableVertexAttribArray(1); 
	glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 4, (const void*)2);



	// 游戏/渲染主循环
	while (!glfwWindowShouldClose(window))
	{
		// 清理屏幕颜色缓冲区
		glClear(GL_COLOR_BUFFER_BIT);

		// 读取当前绑定的缓冲区数据并绘制三角形：从
		// 索引2即第2个顶点开始画，读取三个顶点(
		//并行地读第2个顶点的0号属性_以及_第2个顶点的1号属性)

		//如果是分层布局，比如顶点数据：
		// [V,V, V,V, V,V, V,V, V,V, -->全是位置
		//  T,T, T,T, T,T, T,T, T,T] -->全是纹理
		//那么会同时读取第三组[V,V]和下面第三组[T,T]
		glDrawArrays(GL_TRIANGLES, 2, 3);

		// 交换前后缓冲区以刷新画面
		glfwSwapBuffers(window);

		// 轮询并处理窗口事件（如键盘输入、关闭动作）
		glfwPollEvents();
	}

	// 退出前清理资源
	glfwTerminate();
	return 0;
}

#endif
```





