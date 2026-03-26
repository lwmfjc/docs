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


# 代码

## Render

```cpp
//Render.h
//编译器第一次遇到这个文件，正常读取内容。
//编译器会记下这个文件的物理路径。
//当后续代码再次尝试 #include 这个路径的文件时，编译器直接跳过，不再读取。
#pragma once

#include <GL/glew.h> 

//_debugbreak() 是msvc特有的
//__FILE__和__LINE__ 是所有编译器都支持的
//#x：字符串化操作符。它会将你传入的代码直接转成字符串
//__FILE__ 和 __LINE__：编译器内置宏，自动获取当前代码所在的文件名和行号
#define ASSERT(x) if(!(x)) __debugbreak();
#define GLCall(x) GLClearError();\
	x;\
	ASSERT(GLLogCall(#x,__FILE__,__LINE__));

void GLClearError();

bool GLLogCall(const char* function,
	const char* file, int line);
```

```cpp
//Render.cpp
#include "Render.h"
#include <iostream>

void GLClearError()
{
	//直到不是GL_NO_ERROR，就退出while循环
	while (glGetError() != GL_NO_ERROR);
}

bool GLLogCall(const char* function,
	const char* file, int line)
{
	while (GLenum error = glGetError())
	{
		std::cout << "[OpenGL Error](" << error << "): "
			<< function << " " << file << ":" << line << std::endl;
		return false;
	}

	return true;
}
```

## VertextBuffer

```cpp
//VertextBuffer.h

#pragma once

//专门处理顶点缓冲区的生成、绑定、解绑及内存释放
class VertexBuffer
{
private:
	//一个相关的渲染器id
	unsigned int m_RendererID;
public:
	//size：大小
	VertexBuffer(const void* data, unsigned int size);
	~VertexBuffer();

	void Bind() const;
	void Unbind() const;

};
```

```cpp
//VertexBuffer.cpp
#include "VertexBuffer.h"
#include "Render.h"


VertexBuffer::VertexBuffer(const void* data, unsigned int size)
{ 
	// 生成一个缓冲区 ID
	GLCall(glGenBuffers(1, &m_RendererID));
	// 绑定该 ID 到顶点缓冲区插槽
	GLCall(glBindBuffer(GL_ARRAY_BUFFER, m_RendererID));
	// 将顶点数据从 CPU 内存拷贝到 GPU 显存，设为静态读取模式
	GLCall(glBufferData(GL_ARRAY_BUFFER, size,
		data, GL_STATIC_DRAW));
}

VertexBuffer::~VertexBuffer()
{
	GLCall(glDeleteBuffers(1, &m_RendererID));
}

void VertexBuffer::Bind() const
{
	// 绑定该 ID 到顶点缓冲区插槽
	GLCall(glBindBuffer(GL_ARRAY_BUFFER, m_RendererID));
}

void VertexBuffer::Unbind() const
{
	// 绑定该 ID 到顶点缓冲区插槽
	GLCall(glBindBuffer(GL_ARRAY_BUFFER, 0));
}

```

## IndexBuffer

```cpp
//IndexBuffer.h
#pragma once

//专门处理索引缓冲区的生成、绑定、解绑及内存释放
//索引缓冲区：可以用来只绘制某个面（如果顶点缓冲区
//包括了很多顶点的话）
class IndexBuffer
{
private:
	//一个相关的渲染器id
	unsigned int m_RendererID;
	unsigned int m_Count;
public:
	//count：个数
	IndexBuffer(const unsigned int* data, unsigned int count);
	~IndexBuffer();

	void Bind() const;
	void Unbind() const;

	inline unsigned int GetCount() const { return m_Count; }

};
```

```cpp
//IndexBuffer.cpp
#include "IndexBuffer.h"
#include "Render.h"

IndexBuffer::IndexBuffer(const unsigned int* data, unsigned int count)
	:m_Count(count)
{  
	ASSERT(sizeof(unsigned int) == sizeof(GLuint));
	// 生成一个缓冲区 ID
	GLCall(glGenBuffers(1, &m_RendererID));
	// 绑定该 ID 到元素数组缓冲区 (Element Array Buffer)插槽，
	//也称索引缓冲区对象
	GLCall(glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_RendererID));
	// 将顶点数据从 CPU 内存拷贝到 GPU 显存，设为静态读取模式
	GLCall(glBufferData(GL_ELEMENT_ARRAY_BUFFER, count * sizeof(unsigned int),
		data, GL_STATIC_DRAW));
}

IndexBuffer::~IndexBuffer()
{
	GLCall(glDeleteBuffers(1, &m_RendererID));
}

void IndexBuffer::Bind() const
{
	// 绑定该 ID 到元素数组缓冲区插槽
	GLCall(glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_RendererID));
}

void IndexBuffer::Unbind() const
{
	// 绑定该 ID 到元素数组缓冲区插槽
	GLCall(glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0));
}

```

# VertexBufferLayout

```cpp
//VertexBufferLayout.h
#pragma once
#include <vector>
#include <GL/glew.h>
#include "Render.h"

struct VertexBufferElement
{
	unsigned int type;
	int count;
	unsigned char normalized;

	static unsigned int GetSizeOfType(unsigned int type)
	{
		switch (type)
		{
		case GL_FLOAT: return 4;
		case GL_UNSIGNED_INT: return 4;
		case GL_UNSIGNED_BYTE: return 1;

		}
		ASSERT(false);
		return 0;
	}
};

class VertexBufferLayout
{
private:
	std::vector<VertexBufferElement> m_Elements;
	unsigned int m_Stride;//步长
public :
	VertexBufferLayout()
		:m_Stride(0) {}

	//解释一下，第n个push的就是第n组属性的布局
	template<typename T>
	void Push(int cout)
	{
		static_assert(false);
	}

	//位置 ($x, y, z$)
	template<>
	void Push<float>(int count)
	{
		m_Elements.push_back({ GL_FLOAT,count,GL_FALSE });
		m_Stride += count * VertexBufferElement::GetSizeOfType(GL_FLOAT);
	}

	//ID、索引
	template<>
	void Push<unsigned int >(int count)
	{
		m_Elements.push_back({ GL_UNSIGNED_INT,count,GL_FALSE });
		m_Stride += count * VertexBufferElement::GetSizeOfType(GL_UNSIGNED_INT);
	}

	//颜色 (R, G, B, A)
	//如果你设置 GL_TRUE (归一化)：OpenGL 会自动帮你做除法。比如你传 255，Shader 拿到的是 $255 / 255 = 1.0$；你传 128，Shader 拿到的是 $0.5$
	template<>
	void Push<unsigned char>(int count)
	{
		m_Elements.push_back({ GL_UNSIGNED_BYTE,count,GL_TRUE });
		m_Stride += count * VertexBufferElement::GetSizeOfType(GL_BYTE);
	}

	inline const std::vector<VertexBufferElement> GetElements() const { return m_Elements; }
	inline unsigned int GetStrde() const { return m_Stride; }
};


```

# VertexArray 
```cpp
//VertexArray.h
#pragma once
#include "VertexBuffer.h" 
#include "VertexBufferLayout.h"

class VertexArray
{
private:
	unsigned int m_RendererID;
public:
	VertexArray();
	~VertexArray();

	void AddBuffer(const VertexBuffer& vb, const VertexBufferLayout& layout);

	void Bind() const;
	void Unbind() const;
};

```

```cpp
#include "VertexArray.h"

VertexArray::VertexArray()
{ 
	glGenVertexArrays(1, &m_RendererID);

}

VertexArray::~VertexArray()
{
	glDeleteVertexArrays(1, &m_RendererID);

}

void VertexArray::AddBuffer(const VertexBuffer& vb, const VertexBufferLayout& layout)
{
	Bind();
	vb.Bind();
	const auto& elements = layout.GetElements();
	unsigned int offset = 0;
	for (unsigned int i=0;i<elements.size();i++)
	{
		const auto& element = elements[i];
		// 启用索引为 i 的(顶点)属性 
		glEnableVertexAttribArray(i);
		//1. 打标签：它把当前 GL_ARRAY_BUFFER 里的数据流，贴上了“i号”的标签。2. 定规则：它告诉 GPU，当你（Shader）想要 location = 0 的数据时，请按照“每 count 个 float 为一组”的规则去缓存里抓取。
		glVertexAttribPointer(i, element.count, element.type, element.normalized, layout.GetStrde(), (const void*)offset);

		offset += element.count;
	}

}

void VertexArray::Bind() const
{
	glBindVertexArray(m_RendererID);
}

void VertexArray::Unbind() const
{
	glBindVertexArray(0);

}

```
## Main

```cpp
//Main.cpp
#ifdef LY_EP13
#include <iostream>
#include <GL/glew.h>
#include <GLFW/glfw3.h>
#include <fstream>
#include <sstream>
#include <string>

#include "Render.h"

#include "VertexBuffer.h"
#include "IndexBuffer.h"
#include "VertexArray.h"

struct ShaderProgramSource
{
	std::string VertexSource;
	std::string FragmentSource;
};

static ShaderProgramSource ParseShader(const std::string& filepath)
{

	enum class ShaderType
	{
		NONE = -1, VERTEX = 0, FRAGMENT = 1
	};

	//input file stream
	std::ifstream stream(filepath);

	std::string line;
	std::stringstream ss[2];
	ShaderType type = ShaderType::NONE;

	while (getline(stream, line))
	{
		if (line.find("#shader") != std::string::npos)
		{
			if (line.find("vertex") != std::string::npos)
			{
				type = ShaderType::VERTEX;
			}
			else if (line.find("fragment") != std::string::npos)
			{
				type = ShaderType::FRAGMENT;
			}
		}
		else
		{
			ss[(int)type] << line << '\n';
		}
	}

	return { ss[0].str(),ss[1].str() };

}

//GLenum也就是unsigned int,这里不用GLenum是为了解耦
static unsigned int CompileShader(unsigned int type,
	const std::string& source)
{
	//创建着色器对象，向 OpenGL 申请一个空的“容器”来存放你的代码
	//把光标放在 glCreateShader( 的左括号后面，然后按下 Ctrl + Shift + Space。会弹出一个小黑框，显示：GLuint glCreateShader(GLenum type)
	//到glew.h搜索，发现typedef unsigned int GLenum;
	unsigned int id = glCreateShader(type);
	//返回一个指向该字符串首地址的只读指针（const char*）
	const char* src = source.c_str();

	//有了容器后，你需要把写好的字符串代码塞进去（拷贝）
	//3种用法
	//1. glShaderSource(id, 1, &src, nullptr);	只有一个字符串，且它是以 \0 结尾的。
	//2. glShaderSource(id, 1, &src, &len);	只有一个字符串，长度由 len 指定。
	//3. glShaderSource(id, 2, strings, lengths);	有两个字符串片段（数组形式），长度分别由 lengths[0] 和 lengths[1] 指定。
	glShaderSource(id, 1, &src, nullptr);

	//将你的 GLSL 代码翻译成显卡能理解的机器指令
	glCompileShader(id);

	//错误处理
	int result;

	// 查询编译状态：询问 OpenGL 这个 shader 编译成功了吗？
	// GL_COMPILE_STATUS 会把结果存入 result 中（成功为 GL_TRUE，失败为 GL_FALSE）
	glGetShaderiv(id, GL_COMPILE_STATUS, &result);

	if (result == GL_FALSE)
	{
		int length;
		//获取错误日志长度：如果编译失败，先问一下错误信息一共有多少个字符
		glGetShaderiv(id, GL_INFO_LOG_LENGTH, &length);
		//在栈上申请内存
		//如果申请的内存太大，alloca会导致栈溢出（1MB）
		char* message = (char*)alloca(length * sizeof(char));
		//提取错误信息：把显卡驱动里的具体报错文字拷贝到我们刚才申请的 message 内存中
		glGetShaderInfoLog(id, length, &length, message);
		std::cout << "Failed to compile " << ((type == GL_VERTEX_SHADER) ? "vertex" : "fragment") << " shader!";
		std::cout << message << std::endl;
		//清理：编译失败了，这个 shader 对象也就没用了，删掉它防止内存泄漏
		glDeleteShader(id);
		return 0;
	}


	return id;
}

static unsigned int CreateShader(const std::string& vertexShader,
	const std::string& fragmentShader)
{
	//在 GPU 中申请一个空的“程序对象”
	unsigned int program = glCreateProgram();

	//编译顶点着色器
	unsigned int vs = CompileShader(GL_VERTEX_SHADER,
		vertexShader);
	//编译片段着色器
	unsigned int fs = CompileShader(GL_FRAGMENT_SHADER,
		fragmentShader);

	//把已经编译好的顶点着色器和片段着色器附加到程序对象中
	glAttachShader(program, vs);
	glAttachShader(program, fs);
	//链接
	glLinkProgram(program);
	//验证当前的程序是否能在当前的 OpenGL 状态下执行（
	// 检查顶点着色器的输出是否与片段着色器的输入匹配，并
	// 生成最终的可执行二进制代码。）
	glValidateProgram(program);

	//删除临时的中间产物（类似编译完 C++ 后删除 .obj
	glDeleteShader(vs);
	glDeleteShader(fs);


	return program;
}

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

		glfwSwapInterval(2);

		// 初始化 GLEW 以加载 OpenGL 函数指针，需在有上下文后执行
		if (glewInit() != GLEW_OK)
		{
			std::cout << "Error!" << std::endl;
		}

#pragma endregion

		// 定义三角形的顶点坐标（CPU 内存）
		float positions[] = {
			-0.5f, -0.5f,//0
			0.5f, -0.5f,//1
			0.5f, 0.5f,//2

			//0.5f, 0.5f,
			-0.5f, 0.5f,//3
			//-0.5f, -0.5f,
		};

		//
		unsigned int indices[] = {
			0,1,2,
			2,3,0
		};

		VertexArray va;

		//申请创建一个GPU上的缓冲区，绑定并复制进去数据构造函
		//数中已经绑定了，这样glVertexAttribPointer才有效果
		VertexBuffer vb(positions, 4 * 2 * sizeof(float));

		VertexBufferLayout layout;
		layout.Push<float>(2); 
		va.AddBuffer(vb, layout);

		//申请创建一个GPU上的缓冲区，绑定并复制进去数据
		IndexBuffer ib(indices, 6);

		//这是一个相对路径，相对于 工作目录
		//如果不是在visual studio中运行，就会相对于 可执行文件 所在的目录
		//如果在visual studio中，工作目录被设置为$(ProjectDir) (右键目录-属性-调试-woking directory)
		ShaderProgramSource source = ParseShader("res/shaders/Basic.shader");

		//std::cout << source.VertexSource << std::endl;
		//std::cout << source.FragmentSource << std::endl;

		// 将字符串源码编译并链接成一个完整的程序对象
		unsigned int program = CreateShader(source.VertexSource, source.FragmentSource);
		// 告诉 OpenGL 状态机：接下来的所有绘制指令（如 glDrawArrays）都请使用这个编译好的着色器程序
		// 进行渲染
		glUseProgram(program);


		//===这里故意把他解绑了（假设他去绑定别的去了）===
		vb.Unbind();

		glUseProgram(0);
		va.Unbind();

		//element_array_buffer 和vertexAttribArray不能
		//在解绑vao之前处理，否则就记录进去了
		ib.Unbind();

		glDisableVertexAttribArray(0);
		glDisableVertexAttribArray(1);
		//========================================

		float r = 0.0f;
		float increment = 0.05f;

		// 游戏/渲染主循环
		while (!glfwWindowShouldClose(window))
		{
			// 清理屏幕颜色缓冲区
			glClear(GL_COLOR_BUFFER_BIT);

			//绘图前重新绑定
			glUseProgram(program);

			//必须先绑定program，因为vao不负责着色器程序的切换
			va.Bind();

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
			//glEnableVertexAttribArray(0);
			//glEnableVertexAttribArray(1);

			//最后一个参数：nullptr (或 0)：表示从绑定的 EBO 数据最开头（偏移量为 0）开始读取索引。	非零值：表示从 EBO 的第几个字节开始读取。
			//glDrawElements 的规范（Specification）中明确规定，第三个参数 type 必须是以下三个之一：	GL_UNSIGNED_BYTE，GL_UNSIGNED_SHORT，GL_UNSIGNED_INT，否则会黑屏
			//glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nullptr);
			//GLClearError();
			//参数错误
			GLCall(glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nullptr));

			//ASSERT(GLLogCall());
			//跳过前三个顶点
			//glDrawElements(GL_TRIANGLES, 3, GL_UNSIGNED_INT, (void*)(3 * sizeof(unsigned int)));

			// 交换前后缓冲区以刷新画面
			glfwSwapBuffers(window);

			// 轮询并处理窗口事件（如键盘输入、关闭动作）
			glfwPollEvents();
		}

		//最后解绑vao
		glBindVertexArray(0);

		// 手动通知显卡驱动释放该程序占用的显存
		glDeleteProgram(program);
	}

	// 退出前清理资源
	//glfwTerminate会破坏Context，导致析构函数中的glGetError()
	//返回一个OpenGL错误
	glfwTerminate();
	return 0;
}

#endif

#endif
```