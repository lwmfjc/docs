---
title: 10错误处理
description: 10错误处理
categories:
  - 学习
tags:
  - opengl
  - cherno
date: 2026-03-24T23:05:53+08:00
lastmod: 2026-03-24T23:05:53+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
如何==自动化地捕获 OpenGL 的报错==。由于 OpenGL 是一个状态机且基于 C 语言 API，它不会像现代 C++ 那样抛出异常，所以需要特殊的调试技巧。

# 传统方案：`glGetError`

- ==现状==：OpenGL 的函数执行失败时，屏幕通常只是黑屏，没有任何提示。    
- ==原始手段==：调用 `glGetError()`。它会返回一个错误代码（如 1280 代表 `GL_INVALID_ENUM`）。    
- ==痛点==：这个函数只能一次返回==一个==错误。如果产生了多个错误，你得在一个 `while` 循环里不断调用它才能清空错误队列。

# 进阶方案：封装 `GLClearError` 与 `GLLogCall`

- ==思路==：为了不让主代码被 `glGetError` 淹没，Cherno 进行了宏封装。    
- ==`GLCheckError()`==：在执行 OpenGL 指令==前==调用，用来清空之前的旧错误。    
- ==`GLLogCall()`==：在指令执行==后==调用，检查是否有新错误产生，并打印出==文件名==、==行号==和==具体函数名==。    

# 神奇的宏：`ASSERT` 与 `#` 运算符

- ==自动化==：定义一个 `GLCall(x)` 宏。
    
    ```scss
    #define GLCall(x) GLClearError();\
        x;\
        ASSERT(GLLogCall(#x, __FILE__, __LINE__))
    ```
    
- ==技巧==：
    - `#x`：将代码内容转为字符串。        
    - `__FILE__` 和 `__LINE__`：C++ 内置宏，自动获取报错位置。        
    - `ASSERT`：如果报错，直接让程序停在出问题的那一行，而不是跑飞。


# 现代方案：`glDebugMessageCallback`
~~视频没讲到这个~~  
- ==新特性==：在 OpenGL 4.3+ 版本中引入。    
- ==优势==：这是“被动式”报错。你只需在初始化时设置一个回调函数，一旦 OpenGL 出错，驱动程序会自动跳进你的函数。    
- ==局限性==：虽然更现代，但某些旧显卡驱动支持不佳。Cherno 推荐在学习阶段使用 `GLCall` 宏，因为它兼容性最强且更直观。
# 实战演示：故意写错代码

- ==验证==：Cherno 故意在 `glDrawElements` 里传了一个错误的枚举值。    
- ==结果==：控制台瞬间精准报出了：    
    1.  哪个函数错了（`glDrawElements`）。        
    2.  在哪个文件哪一行。        
    3.  错误代码是什么。

# 💡 博客总结（金句/重点）

|       知识点       |                      关键点                       |
|-----------------|------------------------------------------------|
| ==为什么 OpenGL 不报错？== |          它是 C 风格 API，不提供异常机制，需手动查询状态。          |
|  ==`glGetError` 特点==  |         错误码是累积的，必须循环读取直到返回 `GL_NO_ERROR`。          |
|   ==`GLCall` 宏的作用==   |         它可以包裹任何 `gl` 函数，实现一站式“清空-执行-检查”。         |
|      ==调试效率==       | 配合 `__debugbreak()`（Windows 特有）可以让调试器直接定位到崩掉的那行源码。 |

==在发布版本（Release）中通常要关掉这些报错检查==。因为频繁地通过总线询问 GPU 状态会严重拖慢帧率（FPS）。


# 代码

```cpp
//1. 宏定义

//_debugbreak() 是msvc特有的
//__FILE__和__LINE__ 是所有编译器都支持的
//#x：字符串化操作符。它会将你传入的代码直接转成字符串
//__FILE__ 和 __LINE__：编译器内置宏，自动获取当前代码所在的文件名和行号
#define ASSERT(x) if(!(x)) __debugbreak();
#define GLCall(x) GLClearError();\
	x;\
	ASSERT(GLLogCall(#x,__FILE__,__LINE__));

static void GLClearError()
{
	//直到不是GL_NO_ERROR，就退出while循环
	while (glGetError() != GL_NO_ERROR);
}

static bool GLLogCall(const char* function,
	const char* file,int line)
{ 
	while (GLenum error = glGetError())
	{
		std::cout << "[OpenGL Error](" << error << "): "
			<< function << " " << file << ":" << line << std::endl;
		return false;
	}

	return true;
}


//2. while循环中使用

	while (!glfwWindowShouldClose(window))
	{
		glClear(GL_COLOR_BUFFER_BIT);

		//GLClearError();
		//参数错误
		GLCall(glDrawElements(GL_TRIANGLES, 6, GL_INT, nullptr));
		//ASSERT(GLLogCall()); 
		
		glfwSwapBuffers(window);

		glfwPollEvents();
	}
```