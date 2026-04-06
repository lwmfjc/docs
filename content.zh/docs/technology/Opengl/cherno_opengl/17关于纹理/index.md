---
title: 17关于纹理
description: 17关于纹理
categories:
  - 学习
tags:
  - opengl
  - cherno
date: 2026-03-29T23:43:31+08:00
lastmod: 2026-03-29T23:43:31+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
第 17 集是 OpenGL 系列中视觉效果实现飞跃的一集。在此之前，你只能画出单色的三角形；学完纹理后，你就能把==图片==贴在你的几何图形上。

即便你现在还不学习具体的 API，了解其背后的“映射逻辑”对你理解未来的 3D 渲染至关重要。

# 简述

## 纹理的基本原理：坐标映射

- ==核心概念==：纹理坐标（UV 坐标）。    
- ==UV 坐标系==：    
    - 它是归一化的，$u$ 和 $v$ 的范围都是 $0.0$ 到 $1.0$。        
    - 左下角是 $(0, 0)$，右上角是 $(1, 1)$。
        
- ==映射逻辑==：你在顶点数据中多加两个 float（），告诉 GPU：“这个顶点对应图片上的哪个点”。GPU 会自动在顶点之间进行插值，算出中间每个像素该涂什么颜色。


## 图像加载与 stb\_image

- ==痛点==：OpenGL 本身不认识 `.png` 或 `.jpg` 这种压缩格式。
    
- ==解决方案==：引入一个极简的开源库 ==`stb_image`==。    
    - 这是一个单头文件库，非常符合 Cherno 的极简风格。        
    - 它的作用是==将磁盘上的图片文件解码成内存中的 RGBA 字节数组（即一串 `unsigned char`）==。

## OpenGL 纹理对象 (Texture Object)

- ==创建与绑定==：    
    - 类似于 `VertexBuffer`，你需要 `glGenTextures` 生成一个 ID，然后 `glBindTexture`。
        
- ==关键参数设置 (Parameters)==：    
    - ==过滤 (Filtering)==：当图片被放大或缩小时，像素该怎么补全？（`GL_LINEAR` 线性平滑，或 `GL_NEAREST` 像素风）。        
    - ==包装 (Wrapping)==：当 UV 坐标超过 $1.0$ 时，图片是重复（Repeat）还是拉伸（Clamp）？
        
- ==数据上传==：使用 `glTexImage2D` 将 CPU 内存中的像素数组发送到 GPU 显存。

## 纹理插槽 (Texture Slots)

- ==多纹理支持==：现代显卡可以同时绑定多个纹理（通常是 16 个或 32 个槽位）。    
- ==Slot 0==：默认情况下，我们使用 0 号槽位。    
- ==Uniform 关联==：在 Shader 中，纹理被表示为 `sampler2D` 类型。你需要通过 `glUniform1i` 告诉 Shader：“请去 ==0 号槽位==拿图片数据”。

## 💡 核心技术要点总结

1.  ==数据的扩展==：你的 `VertexBufferLayout` 现在需要 `Push<float>(2)` 来增加纹理坐标属性。    
2.  ==坐标翻转 (Flip)==：OpenGL 默认图片左下角为 ，但大多数图片文件存储是从左上角开始的。Cherno 会教你一行代码 `stbi_set_flip_vertically_on_load(1);` 来解决图像倒置的问题。    
	1.  ~~图像读取是整行整行的读取，原本是先读  ==左上-右上，然后左下-右下==。现在变成了==左下-右下，然后左上-右上==~~ 
	2.  ~~OpenGL像素生成：先水平往右走（填充底部的第一行：左下 $\rightarrow$ 右下）。换行，往上挪一个像素。再水平往右走（填充第二行）。最后到达数组末尾，对应纹理坐标的 $(1, 1)$，即右上角。~~ 
	3.  ~~当你设置了 flip_vertically_on_load(1)，stb_image 在解码完成后（或过程中），会启动一个内存交换逻辑：~~ 
		1.  ~~它会开辟一个临时的行缓冲区。~~ 
		2.  ~~把 第 1 行 和 最后 1 行 的数据在内存地址上进行对调。~~ 
		3.  ~~把 第 2 行 和 倒数第 2 行 对调。~~ 
		4.  ~~以此类推，直到中心。~~ 
3.  ==抽象化==：Cherno 依然会遵循之前的风格，创建一个 `Texture` 类来封装这些繁琐的初始化过程。
## ⚠️ 预热建议（你现在需要知道的）

- ==纹理不是“颜色”==：它是==一块内存数据==。在 Shader 里，你可以拿这块数据当颜色用，也可以拿它当“高度图”或者“法线图”来改变物体的凹凸感。    
- ==文件路径==：从这一集开始，路径问题会成为 Bug 的高发区。确保你的图片放在项目能找到的地方。

# 代码

## Texture

```cpp
#pragma once
#include <string>
class Texture
{
private:
	unsigned int m_RendererID;
	std::string m_FilePath;
	unsigned char* m_LocalBuffer;

	//BPP：它告诉 OpenGL 每一个像素到底由多少个数字组成。如果是 4，OpenGL 就知道按 [R, G, B, A] 的格式去解析数据
	int m_Width, m_Height, m_BPP; //BPP:每像素位数

public:
	Texture(const std::string& path);
	~Texture();
	//想要绑定纹理的插槽
	//一次性可以绑定多个纹理，Windows上可能有32个，取决于显卡
	void Bind(unsigned int slot = 0) const;
	void Unbind() const;
	inline int GetWidth() const { return m_Width; }
	inline int GetHeight() const { return m_Height; }
};
```

```cpp
#include "Texture.h"
#include "Renderer.h"
#include <iostream>

#include "vendor/stb_image/stb_image.h"

Texture::Texture(const std::string& path)
	:m_RendererID(0), m_FilePath(path), m_LocalBuffer(nullptr),
	m_Width(0), m_Height(0), m_BPP(0)
{
	stbi_set_flip_vertically_on_load(1);
	//BPP (Bits Per Pixel)。这里它会告诉你图片原本有多少个通道（比如 JPG 是 3 个，带透明的 PNG 是 4 个）
	//4	强制通道数	最关键的参数。你告诉 stbi：“不管原图是啥样，请通通给我转成 RGBA（4 通道）格式”。
	m_LocalBuffer = stbi_load(path.c_str(), &m_Width, &m_Height, &m_BPP, 4);

	//生成一个缓冲区并绑定到某个id
	glGenTextures(1, &m_RendererID);
	//绑定到这个缓冲区id
	glBindTexture(GL_TEXTURE_2D, m_RendererID);
	
	//设置如何处理纹理边界
	//GL_LINEAR：查看目标像素周围的 4 个像素，取它们的加权平均值
	//GL_NEAREST：只取离目标像素最近的那个像素的值
	//GL_TEXTURE_MIN_FILTER：当纹理被缩小的时候，OpenGL 如何采样纹理
	//GL_TEXTURE_MAG_FILTER：当纹理被放大时，OpenGL 如何采样纹理
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	//当你的纹理坐标（UV 坐标）超出了  0.0 ~ 1.0  这个“标准范围”时，GPU 应该如何处理那些“多出来”的区域
	//GL_CLAMP：当纹理坐标超出标准范围时，GPU 会将纹理坐标限制在 0.0 ~ 1.0 的范围内，并使用边界像素的颜色进行填充。这意味着如果纹理坐标超出范围，GPU 会==重复使用边界像素==的颜色来填充超出部分。
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

	//把这里读到的数据给opengl
	//参数1：GL_TEXTURE_2D：目标类型。告诉 OpenGL 你现在要填充的是一张普通的 2D 纹理。
	//参数2：0：Mipmap 层级(Level)。0 代表原始分辨率（最高级）。如果你以后手动生成多级渐远纹理，这里会用到 1, 2, 3 等。
	//参数3：GL_RGBA8：内部格式(Internal Format)。告诉 OpenGL 你想要在 GPU 内部以什么格式存储这张纹理。GL_RGBA8 表示每个像素使用 4 个字节（32 位）来存储 RGBA 数据。
	//参数4：m_Width：纹理的宽度，以像素为单位。
	//参数5：m_Height：纹理的高度，以像素为单位。
	//参数6：0：边框 (Border)。这是一个遗留参数，在现代 OpenGL 中必须传 0。
	//参数7：GL_RGBA：数据格式。告诉 OpenGL 你提供的数据是 RGBA 格式。
	//参数8：GL_UNSIGNED_BYTE：数据类型。告诉 OpenGL 你提供的数据是无符号字节类型。
	//参数9：m_LocalBuffer：实际的像素数据。
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, m_Width, m_Height, 0, GL_RGBA, GL_UNSIGNED_BYTE, m_LocalBuffer);

	//传给GPU数据后，解绑Texture
	glBindTexture(GL_TEXTURE_2D, 0);

	if (m_LocalBuffer)
	{
		//stbi_image_free 本质上是一个包装过的 free() 函数。
		stbi_image_free(m_LocalBuffer);
	}
	else
	{
		std::cout << "Error: Could not load texture at " << path << std::endl;
	}

}

Texture::~Texture()
{
	//通知GPU销毁指定的纹理资源，并回收那块显存。
	glDeleteTextures(1, &m_RendererID);
}

void Texture::Bind(unsigned int slot /*= 0*/) const
{
	//激活纹理单元
	//激活纹理单元后，后续的 glBindTexture 调用会将该纹理绑定到当前激活的纹理单元。纹理单元 GL\_TEXTURE0 默认始终处于激活状态
	//注：.shader 中的 uniform sampler2D 纹理采样器默认绑定在纹理单元 0 上，所以我们在这里默认绑定到 slot 0 上。这里可以指定某个，这样.shader中就可以去对应的slot上取值了
	glActiveTexture(GL_TEXTURE0 + slot);
	//绑定到这个缓冲区id 
	glBindTexture(GL_TEXTURE_2D, m_RendererID);

}

void Texture::Unbind() const
{
	glBindTexture(GL_TEXTURE_2D, 0);
}

```

## Shader

```Basic.shader
#shader vertex
#version 330 core
layout(location = 0 ) in vec4 position;
layout(location = 1 ) in vec2 texCoord;

out vec2 v_TextCoord;
void main()
{
  gl_Position=position;//自动转换，X, Y, Z：如果缺省，默认补 0.0。W：如果缺省，默认补 1.0
  v_TextCoord=texCoord;//从顶点着色器获取到的又传出来
}


#shader fragment
#version 330 core
//layout(location = 0 ) out vec4 color; //这里应该不需要指定layout
out vec4 color; 

in vec2 v_TextCoord;

uniform vec4 u_Color;//同意u_开头表示uniform变量
uniform sampler2D u_Texture;//目前给了2

void main()
{
  //color=vec4(0.2,0.3,0.8,1.0);
  //对待定纹理坐标进行采样
  //u_Texture: 去 u_Texture 号纹理单元（GL_TEXTURE_N） 找那张已经绑好的图片。
  //v_TextCoord: 纹理坐标，告诉 GPU 从图片的哪个位置采样
  vec4 textColor = texture(u_Texture, v_TextCoord);
  //color=u_Color;
 color=textColor;//只要纹理颜色 

}

```

## Main

```cpp
#ifdef LY_EP17
#include <GL/glew.h>
#include <GLFW/glfw3.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>

#include "Renderer.h"

#include "VertexBuffer.h"
#include "VertexBufferLayout.h"
#include "IndexBuffer.h"
#include "VertexArray.h"
#include "Shader.h"
#include "Texture.h"


int main(void)
{
	{

#pragma region 一些初始化
		GLFWwindow* window;
		// 初始化 GLFW 库，失败则退出
		if (!glfwInit())
			return -1;

		//强制指定使用 Core Profile（核心模式），如果
		//没有手动写着色器则不会渲染；如果不是核心模式，
		//在固定管线中默认颜色是白色，且默认顶点在NDC标准
		//设备坐标系中
		glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
		//这是兼容配置模式,会让VAO0成为默认对象
		//glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_COMPAT_PROFILE);
		glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
		glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);

		//解决白屏问题1：先创建一个不可见的窗口，清屏并交换缓冲后再显示窗口
		glfwWindowHint(GLFW_VISIBLE, GLFW_FALSE);

		// 创建窗口对象
		window = glfwCreateWindow(640, 480, "Hello World", NULL, NULL);
		//验证：创建windows之后马上整个白屏了
		//system("pause");

		if (!window)
		{
			// 创建失败则清理并退出
			glfwTerminate();
			return -1;
		}

		// 将当前窗口的上下文设置为 OpenGL 渲染的目标
		glfwMakeContextCurrent(window);

		glfwSwapInterval(2);

		// 初始化 GLEW 以加载 OpenGL 函数指针，需在有上下文后执行
		if (glewInit() != GLEW_OK)
		{
			std::cout << "Error!" << std::endl;
		}

#pragma endregion

		// 定义三角形的顶点坐标（CPU 内存）
		float positions[] = {
			-0.5f, -0.5f,0.0f,0.0f,//0
			0.5f, -0.5f,1.0f,0.0f,//1
			0.5f, 0.5f,1.0f,1.0f,//2

			//0.5f, 0.5f,
			-0.5f, 0.5f,0.0f,1.0f,//3
			//-0.5f, -0.5f,
		};

		//
		unsigned int indices[] = {
			0,1,2,
			2,3,0
		};

		//默认情况下，OpenGL 是“覆盖”模式。如果一个像素点已经有颜色了（比如背景色），新画上去的像素会直接把旧的顶掉。开启这个开关后，OpenGL 就不再简单地覆盖，而是会把“新颜色”和“旧颜色”按照某种比例混合在一起
		glEnable(GL_BLEND);
		//把要画上去的新颜色称为 源 (Source, 简称 src)，把已经在屏幕上的旧颜色称为 目标 (Destination, 简称 dst)
		//Result = (src x F_src) + (dst x F_dst)
		//F_src表示新颜色的比例，F_dst表示旧颜色的比例。比如 F_src = 0.3，那么GL_ONE_MINUS_SRC_ALPHA时 F_dst = 0.7， GL_SRC_ALPHA时 F_dst = 0.3
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

		VertexArray va;

		//申请创建一个GPU上的缓冲区，绑定并复制进去数据构造函
		//数中已经绑定了，这样glVertexAttribPointer才有效果
		VertexBuffer vb(positions, 4 * 4 * sizeof(float));

		VertexBufferLayout layout;
		layout.Push<float>(2);
		layout.Push<float>(2);
		va.AddBuffer(vb, layout);

		//申请创建一个GPU上的缓冲区，绑定并复制进去数据
		IndexBuffer ib(indices, 6);

		//shader.Bind();

		//shader.SetUniform4f("u_Color", 0.8f, 0.3f, 0.8f, 1.0f);

		//这里绑定了纹理，shader里就能取到
		Texture texture("res/textures/ChernoLog.png");
		texture.Bind(2);//默认绑定0

		//===这里故意把他解绑了（假设他去绑定别的去了）===
		vb.Unbind();

		//shader.Unbind();
		va.Unbind();

		//element_array_buffer 和vertexAttribArray不能
		//在解绑vao之前处理，否则就记录进去了
		ib.Unbind();

		//========================================

		float r = 0.0f;
		float increment = 0.05f;

		Renderer renderer;
		Shader shader("res/shaders/Basic.shader");
		shader.Bind();
		shader.SetUniform1i("u_Texture", 2);

		//解决白屏问题2：在进入 while 循环前，手动清一次屏并交换缓冲
		//设置“清除颜色”
		glClearColor(0.2f, 0.3f, 0.3f, 1.0f);		
		//用上面选好的“油漆”填满整个颜色缓冲区（Color Buffer）
		glClear(GL_COLOR_BUFFER_BIT);
		//交换缓冲区
		glfwSwapBuffers(window); // 这一步把“深绿色”推送到显卡
		//解决白屏问题3：最后才显示窗口
		glfwShowWindow(window);

		// 游戏/渲染主循环
		while (!glfwWindowShouldClose(window))
		{
			// 清理屏幕颜色缓冲区
			renderer.Clear();


			//必须先绑定program，因为vao不负责着色器程序的切换
			//va.Bind();

			if (r > 1.0f)
				increment = -0.05f;
			else if (r < 0.0f)
				increment = 0.05f;

			r += increment;

			//绘图前重新绑定
			shader.Bind();
			//在u_Color的位置上设置数值
			shader.SetUniform4f("u_Color", r, 0.3f, 0.0f, 1.0f);
			//========设置uniform========

			renderer.Draw(va, ib, shader);


			// 交换前后缓冲区以刷新画面
			glfwSwapBuffers(window);

			// 轮询并处理窗口事件（如键盘输入、关闭动作）
			glfwPollEvents();
		}

		//最后解绑vao
		//glBindVertexArray(0);
	}

	// 退出前清理资源
	//glfwTerminate会破坏Context，导致析构函数中的glGetError()
	//返回一个OpenGL错误
	glfwTerminate();
	return 0;
}

#endif
```

