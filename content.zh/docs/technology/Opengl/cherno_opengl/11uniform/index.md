---
title: 11uniform
description: 11uniform
categories:
  - 学习
tags:
  - cherno
  - opengl
date: 2026-03-25T07:52:27+08:00
lastmod: 2026-03-25T07:52:27+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
在之前的章节里，颜色是硬编码在着色器里的，而这一集教你如何从 CPU（C++ 代码）动态地控制 GPU 里的变量。

# 总结

## 什么是 Uniform？

- ==定义==：Uniform 是从 CPU 向 Shader 传递数据的桥梁。    
- ==特性==：    
    - ==“统一”性==：在一个 Draw Call（绘制指令）中，所有的顶点和像素看到的 Uniform 值都是完全一样的。        
    - ==对比==：与 `attributes`（顶点属性）不同，属性是每个顶点都可能不同的（如坐标），而 Uniform 是全局一致的。        
- ==用途==：最常用于传递颜色、变换矩阵（旋转/平移/缩放）、纹理采样器等。
  
> uniform变量依赖 *PCIe 总线* 进行 CPU 到 GPU 的数据拷贝。在 GPU 内部，Uniform 并不像顶点属性（Attribute）那样存在于一个巨大的流缓冲区中。它存储在 GPU 专门划拨的一块==常量寄存器（Constant Registers）或统一常量缓冲区（Uniform Storage）==中。在 Shader 运行期间，Uniform 是只读的 ~~Uniform 的“只读”是指 单个 Draw Call 执行期间 它是静态的。在不同的 Draw Call 之间，你可以随意修改它。~~   
## 在 Shader 中声明 Uniform

- ==语法==：在 GLSL 中使用 `uniform` 关键字。    
- ==命名规范==：Cherno 推荐使用 `u_` 前缀（如 `u_Color`），以便在代码中快速区分。
- ==代码示例==：

```Fragment
    #shader fragment
    #version 330 core
    layout(location = 0) out vec4 color;
    uniform vec4 u_Color; // 声明 Uniform
    void main() {
        color = u_Color; // 使用该变量
    };
```

## 获取 Uniform 的位置 (Location)

- ==核心函数==：`glGetUniformLocation(program, "u_Color")`。    
- ==逻辑==：你不能直接往变量名里塞数据，必须先问 OpenGL：这个变量在显存里的“槽位”是多少？
    
- ==注意事项==：    
  
    - 如果变量在 Shader 里定义了但==没被使用==，编译器会把它优化掉，此时返回的 Location 会是 `-1`。        
    - 这是一个 CPU 密集型操作，Cherno 提到后续会通过“缓存（Cache）”来优化它。        

## 设置 Uniform 的值 (glUniform)

- ==函数族==：OpenGL 是 C 语言 API，不支持重载，所以有一系列后缀函数：    
    - `glUniform4f`：传 4 个 float。        
    - `glUniform1i`：传 1 个 integer（常用于纹理）。        
- ==先决条件==：在调用 `glUniform` 之前，==必须==先调用 `glUseProgram(shader)` 绑定当前的着色器。    

## 实战：动态改变颜色（动画效果）

- ==逻辑实现==：    
    1.  在 `while` 循环外定义一个 `float r = 0.0f;` 和一个增量 `increment = 0.05f;`。        
    2.  每一帧改变 `r` 的值。        
    3.  调用 `glUniform4f(location, r, 0.3f, 0.8f, 1.0f);`。        
- ==结果==：运行程序后，你会看到矩形的颜色随时间平滑地发生变化。    
  
```cpp




	// 告诉 OpenGL 状态机：接下来的所有绘制指令（如 glDrawArrays）都请使用这个编译好的着色器程序
	// 进行渲染
	glUseProgram(program);

	//==在绑定程序后，获取变量地址，然后设置变量==
	//问着色器，让着色器告诉CPU变量的位置
	unsigned int location = glGetUniformLocation (program, "u_Color");
	//不为1时会报错并且停止程序（当设置了变量但是着色器没
	//使用过时，OpenGL会在编译时删除那个变量）
	ASSERT(location != -1);

	float r = 0.0f;
	float increment = 0.05f;

	// 游戏/渲染主循环
	while (!glfwWindowShouldClose(window))
	{
		// 清理屏幕颜色缓冲区
		glClear(GL_COLOR_BUFFER_BIT); 

		if (r > 1.0f)
			increment = -0.05f;
		else if (r < 0.0f)
			increment = 0.05f;

		r += increment;

		//在u_Color的位置上设置数值
		glUniform4f(location, r, 0.3f, 0.0f, 1.0f);

		GLCall(glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nullptr)); 
		// 交换前后缓冲区以刷新画面
		glfwSwapBuffers(window);

		// 轮询并处理窗口事件（如键盘输入、关闭动作）
		glfwPollEvents();
	}

	// 手动通知显卡驱动释放该程序占用的显存
	glDeleteProgram(program);

	// 退出前清理资源
	glfwTerminate();
	return 0;
}
```

## 总结与调试技巧

- ==报错检查==：如果颜色没变，检查是否使用了 `GLCall` 宏包裹 `glUniform`。    
- ==下集预告==：现在代码越来越臃肿，第 12 集将开始进行 ==Vertex Array（顶点数组对象）== 的封装。

## 💡 博客小建议：

在博客中可以特别提到 ==`4f`== 后缀的含义：
- ==4==：代表有 4 个分量（R, G, B, A）。    
- ==f==：代表数据类型是 `float`。 这也是 OpenGL 这种 C 风格接口的一个典型特征。
# 附：解释一下glfwSwapInterval

这行代码 `glfwSwapInterval(1);` 是图形开发中非常关键的一个设置，它的专业术语叫做 ==开启垂直同步（V-Sync）==。

简单来说，它的作用是：==限制你的游戏/程序帧率，使其与显示器的刷新率保持一致。==

## 1\. 为什么需要它？（解决“画面撕裂”）

如果你的显卡性能很强，每秒能渲染 200 帧，但你的显示器刷新率只有 60Hz（每秒只能显示 60 张图）。

- ==没有 V-Sync==：显卡会不管不顾地把渲染好的数据往显示器里塞。结果显示器在刷屏刷到一半时，显卡又送来了一张新图。于是你会在屏幕上看到==上半截是旧画面，下半截是新画面==。    
- ==有了 V-Sync==：显卡会等显示器刷完一屏后，再发出下一帧。

## 2\. 参数 `1` 是什么意思？

这个函数接受一个整数作为参数：

- ==`0`==：==关闭垂直同步==。显卡跑多快就传多快，帧率（FPS）不设上限。
- ==`1`==：==开启垂直同步==。每刷新 1 个屏幕周期，才交换一次缓冲区（Swap Buffers）。如果显示器是 60Hz，你的程序就会被锁定在 60 FPS。    
- ==`2`==（较少用）：每刷新 2 个周期才交换一次。如果显示器是 60Hz，你的程序会被锁定在 30 FPS。
## 3\. 在 Cherno 第 11 集里的具体用途

你在这一集里写了一个==颜色循环动画==：

```makefile
r += increment;
```

- ==如果 `SwapInterval(0)`==：你的循环会跑得飞快（几千 FPS），你会发现颜色闪烁得快到肉眼看不清，像坏掉的霓虹灯。    
- ==如果 `SwapInterval(1)`==：程序被限制在 60 FPS，`increment` 的累加速度变得稳定且可控，你会看到颜色平滑、优雅地变幻。
## 4\. 为什么必须在 `glfwMakeContextCurrent` 之后调用？

- ==逻辑==：`glfwSwapInterval` 是针对“当前 OpenGL 上下文”的操作。    
- ==底层==：如果你还没把 `window` 设为当前上下文（Context），你就去设间隔，OpenGL 根本不知道你在给哪个窗口下命令，这行代码就会失效。