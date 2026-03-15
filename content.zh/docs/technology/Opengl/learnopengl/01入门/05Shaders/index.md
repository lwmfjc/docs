---
title: 05Shaders
description: 05Shaders
categories:
  - 学习
tags:
  - learnopengl
  - opengl
date: 2026-03-15T19:43:26+08:00
lastmod: 2026-03-15T19:43:26+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
## 着色器

正如 [“你好，三角形”](https://learnopengl.com/Getting-started/Hello-Triangle) 一章中所述，着色器是运行在 GPU 上的小型程序。这些程序在图形管线的每个特定阶段运行。从本质上讲，着色器就是将输入转换为输出的程序。着色器也是高度隔离的程序，它们之间不允许通信；它们之间唯一的通信方式是通过输入和输出。

上一章我们简要介绍了着色器及其正确使用方法。现在我们将更全面地解释着色器，特别是 OpenGL 着色语言。

## GLSL

着色器是用类似 C 语言的 GLSL 编写的。GLSL 专为图形处理而设计，包含专门针对向量和矩阵操作的实用功能。

着色器总是以版本声明开始，后面跟着输入输出变量列表、uniform 变量以及主函数。每个着色器的入口点都在其主函数中，该函数处理所有输入变量并将结果输出到输出变量中。如果您不了解 uniform 变量，请不要担心，我们稍后会讲解。

着色器通常具有以下结构：

```typescript
#version version_number
in type in_variable_name;
in type in_variable_name;

out type out_variable_name;
  
uniform type uniform_name;
  
void main()
{
  // process input(s) and do some weird graphics stuff
  ...
  // output processed stuff to output variable
  out_variable_name = weird_stuff_we_processed;
}
```

当我们专门讨论顶点着色器时，每个输入变量也称为顶点属性。我们可以声明的顶点属性数量受硬件限制。OpenGL 保证始终至少有 16 个 4 分量顶点属性可用，但某些硬件可能允许更多，您可以通过查询 GL\_MAX\_VERTEX\_ATTRIBS 来获取这些信息：

```cpp
int nrAttributes;
glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &nrAttributes);
std::cout << "Maximum nr of vertex attributes supported: " << nrAttributes << std::endl;
```

这通常会返回最小值 `16` ，这对于大多数用途来说应该绰绰有余。

## 类型

与其他编程语言一样，GLSL 也拥有数据类型，用于指定我们要操作的变量类型。GLSL 包含了我们在 C 等语言中常见的绝大多数默认基本类型： `int` 、 `float` 、 `double` 、 `uint` 和 `bool` 还提供了两种我们将经常用到的容器类型： `vectors` 和 `matrices` 。我们将在后面的章节中讨论矩阵。

### 向量

在 GLSL 中，向量是一个包含 2、3 或 4 个分量的容器，用于容纳前面提到的任何基本类型。它们可以采用以下形式（ `n` 表示分量数）：

-   `vecn` ：默认的 `n` 浮点数的向量。
-   `bvecn` ：一个包含 `n` 布尔值的向量。
-   `ivecn` ：一个包含 `n` 整数的向量。
-   `uvecn` ：一个包含 `n` 无符号整数的向量。
-   `dvecn` ：一个包含 `n` 双分量的向量。

大多数情况下，我们将使用基本 `vecn` 因为浮点数足以满足我们的大多数用途。

可以通过 `vec.x` 访问向量的各个分量，其中 `x` 是向量的第一个分量。您可以使用 `.x` 、 `.y` 、 `.z` 和 `.w` 分别访问向量的第一、第二、第三和第四个分量。GLSL 还允许您使用 `rgba` 表示颜色，或使用 `stpq` 表示纹理坐标，访问的也是相同的分量。

向量数据类型允许进行一些有趣且灵活的组件选择，称为“组件交换”（swizzling）。组件交换允许我们使用如下语法：

```java
vec2 someVec;
vec4 differentVec = someVec.xyxx;
vec3 anotherVec = differentVec.zyw;
vec4 otherVec = someVec.xxxx + anotherVec.yxzy;
```

您可以使用最多 4 个字母的任意组合来创建一个新的（相同类型的）向量，只要原始向量包含这些分量即可；例如，不允许访问 `vec2` 向量的 `.z` 分量。我们还可以将向量作为参数传递给不同的向量构造函数调用，从而减少所需的参数数量：

```java
vec2 vect = vec2(0.5, 0.7);
vec4 result = vec4(vect, 0.0, 0.0);
vec4 otherResult = vec4(result.xyz, 1.0);
```

因此，向量是一种灵活的数据类型，我们可以将其用于各种输入和输出。本书中将提供大量示例，展示我们如何创造性地管理向量。

## 来来往往

着色器本身就是很棒的小程序，但它们是整体的一部分，因此我们需要为每个着色器设置输入和输出，以便进行数据传递。GLSL 专门为此定义了 \` `in` 和 \` `out` 关键字。每个着色器都可以使用这些关键字指定输入和输出，当输出变量与下一着色器阶段的输入变量匹配时，它们就会被传递下去。不过，顶点着色器和片段着色器略有不同。

顶点着色器 **需要**接收某种形式的输入，否则它将非常低效。顶点着色器的输入方式与其他着色器不同，它直接从顶点数据接收输入。为了定义顶点数据的组织方式，我们需要使用位置元数据来指定输入变量，以便在 CPU 上配置顶点属性。我们在上一章中已经见过这种做法，即 `layout (location = 0)` 。因此，顶点着色器需要为其输入添加额外的布局规范，以便将其与顶点数据关联起来。

也可以省略 `layout (location = 0)` 指定符，直接在 OpenGL 代码中使用 glGetAttribLocation 查询属性位置，但我更倾向于在顶点着色器中设置它们。这样更容易理解，也能为你（以及 OpenGL）节省一些工作。

另一个例外是，片段着色器需要一个 `vec4` 颜色输出变量，因为片段着色器需要生成最终的输出颜色。如果在片段着色器中未指定输出颜色，则这些片段的颜色缓冲区输出将未定义（通常意味着 OpenGL 会将它们渲染为黑色或白色）。

因此，如果我们想将数据从一个着色器发送到另一个着色器，我们需要在发送着色器中声明一个输出，并在接收着色器中声明一个类似的输入。当两端的类型和名称都相同时，OpenGL 会将这些变量链接起来，然后就可以在着色器之间发送数据了（这是通过链接程序对象实现的）。为了向您展示这在实践中的工作原理，我们将修改上一章中的着色器，让顶点着色器决定片段着色器的颜色。

**顶点着色器**

```csharp
#version 330 core
layout (location = 0) in vec3 aPos; // the position variable has attribute position 0
  
out vec4 vertexColor; // specify a color output to the fragment shader

void main()
{
    gl_Position = vec4(aPos, 1.0); // see how we directly give a vec3 to vec4's constructor
    vertexColor = vec4(0.5, 0.0, 0.0, 1.0); // set the output variable to a dark-red color
}
```

**片段着色器**

```csharp
#version 330 core
out vec4 FragColor;
  
in vec4 vertexColor; // the input variable from the vertex shader (same name and same type)  

void main()
{
    FragColor = vertexColor;
}
```

可以看到，我们在顶点着色器中声明了一个 vertexColor 变量，并将其设置为 `vec4` 输出；同时，我们在片段着色器中也声明了一个类似的 vertexColor 输入。由于它们的类型和名称相同，片段着色器中的 vertexColor 与顶点着色器中的 vertexColor 相关联。因为我们在顶点着色器中将颜色设置为深红色，所以生成的片段也应该是深红色。下图显示了输出结果：

![](https://learnopengl.com/img/getting-started/shaders.png)

搞定了！我们刚刚成功地将一个值从顶点着色器传递到了片段着色器。让我们再加点料，看看能不能将一个颜色从我们的应用程序传递到片段着色器！

## 制服

Uniform 是另一种将数据从 CPU 上的应用程序传递到 GPU 上的着色器的方法。不过，Uniform 与顶点属性略有不同。首先，Uniform 是全局的。全局意味着每个着色器程序对象中的 uniform 变量都是唯一的，并且可以在着色器程序的任何阶段从任何着色器访问。其次，无论您将 uniform 值设置为什么，它都会一直保持该值，直到被重置或更新。

在 GLSL 中声明 uniform 变量，只需在着色器中添加 `uniform` 关键字，并指定类型和名称即可。之后，我们就可以在着色器中使用新声明的 uniform 变量了。让我们看看这次是否可以通过 uniform 变量来设置三角形的颜色：

```csharp
#version 330 core
out vec4 FragColor;
  
uniform vec4 ourColor; // we set this variable in the OpenGL code.

void main()
{
    FragColor = ourColor;
}
```

我们在片段着色器中声明了一个名为 ourColor 的 uniform vec4 ，并将片段的输出颜色设置为该 uniform 变量的值。由于 uniform 变量是全局变量，我们可以在任何着色器阶段定义它们，因此无需再次通过顶点着色器将值传递给片段着色器。我们没有在顶点着色器中使用这个 uniform 变量，所以无需在那里定义它。

如果您声明了一个在 GLSL 代码中任何地方都没有使用的 uniform 变量，编译器会默默地从编译后的版本中删除该变量，这会导致一些令人沮丧的错误；请记住这一点！

目前 uniform 变量为空；我们还没有向 uniform 变量添加任何数据，所以让我们来尝试一下。首先，我们需要在着色器中找到 uniform 变量属性的索引/位置。一旦我们找到了 uniform 变量的索引/位置，我们就可以更新它的值了。与其向片段着色器传递单一颜色，不如让颜色随时间逐渐变化，这样会更有趣：

```cpp
float timeValue = glfwGetTime();
float greenValue = (sin(timeValue) / 2.0f) + 0.5f;
int vertexColorLocation = glGetUniformLocation(shaderProgram, "ourColor");
glUseProgram(shaderProgram);
glUniform4f(vertexColorLocation, 0.0f, greenValue, 0.0f, 1.0f);
```

首先，我们通过 glfwGetTime() 获取运行时间（以秒为单位）。然后，我们使用 sin 函数将颜色在 `0.0` - `1.0` 的范围内变化，并将结果存储在 greenValue 中。

然后我们使用 glGetUniformLocation 函数查询 ourColor uniform 变量的位置。我们需要将着色器程序和 uniform 变量（我们要从中获取位置信息）的名称传递给查询函数。如果 glGetUniformLocation 返回 `-1` ，则表示找不到该位置。最后，我们可以使用 glUniform4f 函数设置 uniform 变量的值。请注意，查找 uniform 变量的位置不需要先调用着色器程序，但更新 uniform 变量**则**需要先调用着色器程序（通过调用 glUseProgram），因为它会将 uniform 变量的值设置到当前活动的着色器程序上。

由于 OpenGL 本质上是一个 C 库，它本身并不支持函数重载，因此，凡是需要使用不同类型调用的函数，OpenGL 都会为每种类型定义新的函数；glUniform 就是一个很好的例子。该函数需要一个特定的后缀来指定要设置的 uniform 变量的类型。以下是一些可能的后缀：

-   `f` ：该函数需要一个 `float` 作为其值。
-   `i` ：该函数需要一个 `int` 数值。
-   `ui` ：该函数需要一个 `unsigned int` 作为其值。
-   `3f` ：该函数需要 3 个 `float` 作为其值。
-   `fv` ：该函数需要一个 `float` 向量/数组作为其值。

每当您想要配置 OpenGL 的某个选项时，只需选择与您的类型对应的重载函数即可。在本例中，我们希望分别设置 uniform 变量中的 4 个浮点数，因此我们通过 glUniform4f 传递数据（请注意，我们也可以使用 `fv` 版本）。

现在我们知道了如何设置 uniform 变量的值，就可以用它们进行渲染了。如果想要颜色逐渐变化，就需要每帧都更新这个 uniform 变量，否则如果只设置一次，三角形就会保持单一的纯色。所以我们计算 greenValue 值 ，并在每次渲染迭代中更新 uniform 变量：

```cpp
while(!glfwWindowShouldClose(window))
{
    // input
    processInput(window);

    // render
    // clear the colorbuffer
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    // be sure to activate the shader
    glUseProgram(shaderProgram);
  
    // update the uniform color
    float timeValue = glfwGetTime();
    float greenValue = sin(timeValue) / 2.0f + 0.5f;
    int vertexColorLocation = glGetUniformLocation(shaderProgram, "ourColor");
    glUniform4f(vertexColorLocation, 0.0f, greenValue, 0.0f, 1.0f);

    // now render the triangle
    glBindVertexArray(VAO);
    glDrawArrays(GL_TRIANGLES, 0, 3);
  
    // swap buffers and poll IO events
    glfwSwapBuffers(window);
    glfwPollEvents();
}
```

这段代码是对之前代码的相对简单的修改。这次，我们在每一帧绘制三角形之前都会更新一个统一变量的值。如果正确更新了该统一变量，你应该会看到三角形的颜色从绿色逐渐变为黑色，然后再变回绿色。

 ![](https://learnopengl.com/img/getting-started/shaders2.png)

如果遇到问题，可以查看 [这里的](https://learnopengl.com/code_viewer_gh.php?code=src/1.getting_started/3.1.shaders_uniform/shaders_uniform.cpp)源代码。

如您所见，uniform 变量是设置每帧可能变化的属性或在应用程序和着色器之间交换数据的实用工具。但如果我们想为每个顶点设置颜色呢？在这种情况下，我们需要声明与顶点数量相同的 uniform 变量。更好的解决方案是在顶点属性中包含更多数据，这也是我们接下来要做的事情。

## 更多属性！

我们在上一章中学习了如何填充 VBO、配置顶点属性指针并将其存储在 VAO 中。这次，我们还要向顶点数据中添加颜色数据。我们将以 3 个 `float` 的形式向顶点数组添加颜色数据。我们分别将红色、绿色和蓝色分配给三角形的每个角：

```cpp
float vertices[] = {
    // positions         // colors
     0.5f, -0.5f, 0.0f,  1.0f, 0.0f, 0.0f,   // bottom right
    -0.5f, -0.5f, 0.0f,  0.0f, 1.0f, 0.0f,   // bottom left
     0.0f,  0.5f, 0.0f,  0.0f, 0.0f, 1.0f    // top 
};
```

由于现在需要向顶点着色器发送更多数据，因此必须调整顶点着色器，使其也能接收颜色值作为顶点属性输入。请注意，我们使用布局说明符将 aColor 属性的位置设置为 1：

```csharp
#version 330 core
layout (location = 0) in vec3 aPos;   // the position variable has attribute position 0
layout (location = 1) in vec3 aColor; // the color variable has attribute position 1
  
out vec3 ourColor; // output a color to the fragment shader

void main()
{
    gl_Position = vec4(aPos, 1.0);
    ourColor = aColor; // set ourColor to the input color we got from the vertex data
}
```

由于我们不再使用 uniform 变量来表示片段的颜色，而是使用 ourColor 输出变量，因此我们也必须更改片段着色器：

```csharp
#version 330 core
out vec4 FragColor;  
in vec3 ourColor;
  
void main()
{
    FragColor = vec4(ourColor, 1.0);
}
```

由于我们添加了一个新的顶点属性并更新了 VBO 的内存，因此我们需要重新配置顶点属性指针。更新后的 VBO 内存中的数据现在看起来大致如下：

![Interleaved data of position and color within VBO to be configured wtih <function id='30'>glVertexAttribPointer</function>](https://learnopengl.com/img/getting-started/vertex_attribute_pointer_interleaved.png)

了解当前布局后，我们可以使用 glVertexAttribPointer 更新顶点格式：

```scss
// position attribute
glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*)0);
glEnableVertexAttribArray(0);
// color attribute
glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*)(3* sizeof(float)));
glEnableVertexAttribArray(1);
```

glVertexAttribPointer 的前几个参数相对简单。这次我们配置的是属性位置 `1` 顶点属性。颜色值的大小为 `3` `float` ，并且我们不对这些值进行归一化。

由于现在我们有两个顶点属性，因此需要重新计算 _步长_值。为了获取数据数组中的下一个属性值（例如位置向量的下一个 `x` 分量），我们需要向右移动 `6` `float` ，其中 3 个用于位置值，3 个用于颜色值。这样得到的步长值是 `float` 大小的 6 倍（以字节为单位，即 `24` 字节）。  
此外，这次我们还需要指定偏移量。对于每个顶点，位置顶点属性位于最前面，因此我们声明偏移量为 `0` 颜色属性位于位置数据之后，因此偏移量为 `3 * sizeof(float)` 字节（= `12` 字节）。

运行该应用程序后，应该会显示以下图像：

![](https://learnopengl.com/img/getting-started/shaders3.png)

如果遇到问题，可以查看 [这里的](https://learnopengl.com/code_viewer_gh.php?code=src/1.getting_started/3.2.shaders_interpolation/shaders_interpolation.cpp)源代码。

由于我们只提供了三种颜色，而不是现在看到的庞大调色板，所以图像可能与您预期的略有不同。这都是片段着色器中称为片段插值技术的结果。渲染三角形时，光栅化阶段通常会生成比最初指定的顶点数多得多的片段。然后，光栅化器会根据每个片段在三角形形状上的位置来确定它们的具体位置。  
基于这些位置，它会对片段着色器的所有输入变量进行插值。例如，假设我们有一条线，其上点为绿色，下点为蓝色。如果片段着色器在位于该线段约 `70%` 位置的片段上运行，则其最终的颜色输入属性将是绿色和蓝色的线性组合；更准确地说： `30%` 蓝色和 `70%` 绿色。

这正是三角形的实际情况。它有三个顶点，因此有三种颜色。从三角形的像素数量来看，它可能包含大约 50000 个片段，片段着色器在这些片段之间进行颜色插值。仔细观察这些颜色，你会发现一切都说得通：红色到蓝色先过渡到紫色，然后再过渡到蓝色。片段插值应用于片段着色器的所有输入属性。

## 我们自己的着色器类

编写、编译和管理着色器可能相当繁琐。作为着色器主题的最后总结，我们将通过构建一个着色器类来简化我们的工作。该类可以从磁盘读取着色器，编译并链接它们，检查错误，并且易于使用。这也有助于您了解如何将我们目前所学的一些知识封装到有用的抽象对象中。

我们将把着色器类完全放在一个头文件中，主要目的是为了学习和提高可移植性。首先，让我们添加必要的头文件并定义类结构：

```cpp
#ifndef SHADER_H
#define SHADER_H

#include <glad/glad.h> // include glad to get all the required OpenGL headers
  
#include <string>
#include <fstream>
#include <sstream>
#include <iostream>
  

class Shader
{
public:
    // the program ID
    unsigned int ID;
  
    // constructor reads and builds the shader
    Shader(const char* vertexPath, const char* fragmentPath);
    // use/activate the shader
    void use();
    // utility uniform functions
    void setBool(const std::string &name, bool value) const;  
    void setInt(const std::string &name, int value) const;   
    void setFloat(const std::string &name, float value) const;
};
  
#endif
```

我们在头文件顶部使用了几个预处理器指令。这些简短的代码会告诉编译器，即使多个文件都包含了着色器头文件，也只有在该头文件尚未被包含的情况下才包含并编译它。这样可以避免链接冲突。

着色器类保存着着色器程序的 ID。它的构造函数需要顶点着色器和片段着色器的源代码文件路径，我们可以将这些文件以纯文本文件的形式存储在磁盘上。为了方便起见，我们还添加了一些实用函数：\`use\` 函数用于激活着色器程序，而 \`set...\` 函数则用于查询 uniform 变量的位置并设置其值。

## 从文件读取

我们使用 C++ 文件流将文件中的内容读取到多个 `string` 对象中：

```rust
Shader(const char* vertexPath, const char* fragmentPath)
{
    // 1. retrieve the vertex/fragment source code from filePath
    std::string vertexCode;
    std::string fragmentCode;
    std::ifstream vShaderFile;
    std::ifstream fShaderFile;
    // ensure ifstream objects can throw exceptions:
    vShaderFile.exceptions (std::ifstream::failbit | std::ifstream::badbit);
    fShaderFile.exceptions (std::ifstream::failbit | std::ifstream::badbit);
    try 
    {
        // open files
        vShaderFile.open(vertexPath);
        fShaderFile.open(fragmentPath);
        std::stringstream vShaderStream, fShaderStream;
        // read file's buffer contents into streams
        vShaderStream << vShaderFile.rdbuf();
        fShaderStream << fShaderFile.rdbuf();
        // close file handlers
        vShaderFile.close();
        fShaderFile.close();
        // convert stream into string
        vertexCode   = vShaderStream.str();
        fragmentCode = fShaderStream.str();
    }
    catch(std::ifstream::failure e)
    {
        std::cout << "ERROR::SHADER::FILE_NOT_SUCCESFULLY_READ" << std::endl;
    }
    const char* vShaderCode = vertexCode.c_str();
    const char* fShaderCode = fragmentCode.c_str();
    [...]
```

接下来我们需要编译和链接着色器。请注意，我们还会检查编译/链接是否失败，如果失败，则打印编译时错误。这在调试时非常有用（您最终会需要这些错误日志）：

```cpp
// 2. compile shaders
unsigned int vertex, fragment;
int success;
char infoLog[512];
   
// vertex Shader
vertex = glCreateShader(GL_VERTEX_SHADER);
glShaderSource(vertex, 1, &vShaderCode, NULL);
glCompileShader(vertex);
// print compile errors if any
glGetShaderiv(vertex, GL_COMPILE_STATUS, &success);
if(!success)
{
    glGetShaderInfoLog(vertex, 512, NULL, infoLog);
    std::cout << "ERROR::SHADER::VERTEX::COMPILATION_FAILED\n" << infoLog << std::endl;
};
  
// similiar for Fragment Shader
[...]
  
// shader Program
ID = glCreateProgram();
glAttachShader(ID, vertex);
glAttachShader(ID, fragment);
glLinkProgram(ID);
// print linking errors if any
glGetProgramiv(ID, GL_LINK_STATUS, &success);
if(!success)
{
    glGetProgramInfoLog(ID, 512, NULL, infoLog);
    std::cout << "ERROR::SHADER::PROGRAM::LINKING_FAILED\n" << infoLog << std::endl;
}
  
// delete the shaders as they're linked into our program now and no longer necessary
glDeleteShader(vertex);
glDeleteShader(fragment);
```

使用方法很简单：

```csharp
void use() 
{ 
    glUseProgram(ID);
}
```

同样适用于任何统一设置函数：

```csharp
void setBool(const std::string &name, bool value) const
{         
    glUniform1i(glGetUniformLocation(ID, name.c_str()), (int)value); 
}
void setInt(const std::string &name, int value) const
{ 
    glUniform1i(glGetUniformLocation(ID, name.c_str()), value); 
}
void setFloat(const std::string &name, float value) const
{ 
    glUniform1f(glGetUniformLocation(ID, name.c_str()), value); 
}
```

好了，一个完整的 [着色器类](https://learnopengl.com/code_viewer_gh.php?code=includes/learnopengl/shader_s.h)就完成了。使用着色器类非常简单；我们只需创建一次着色器对象，之后就可以直接使用它了：

```scss
Shader ourShader("path/to/shaders/shader.vs", "path/to/shaders/shader.fs");
[...]
while(...)
{
    ourShader.use();
    ourShader.setFloat("someUniform", 1.0f);
    DrawStuff();
}
```

这里我们将顶点着色器和片段着色器的源代码分别存储在名为 `shader.vs` 和 `shader.fs` 的两个文件中。您可以随意命名着色器文件；我个人觉得 `.vs` 和 `.fs` 这两个扩展名非常直观。

您可以 [在这里](https://learnopengl.com/code_viewer_gh.php?code=src/1.getting_started/3.3.shaders_class/shaders_class.cpp)找到我们新创建的[着色器类的](https://learnopengl.com/code_viewer_gh.php?code=includes/learnopengl/shader_s.h)源代码。请注意，您可以点击着色器文件路径来查找着色器的源代码。

## 练习

1.  调整顶点着色器，使三角形倒置： [解决方案](https://learnopengl.com/code_viewer_gh.php?code=src/1.getting_started/3.4.shaders_exercise1/shaders_exercise1.cpp) 。
2.  通过 uniform 变量指定水平偏移量，并在顶点着色器中使用此偏移值将三角形移动到屏幕右侧： [解决方案](https://learnopengl.com/code_viewer_gh.php?code=src/1.getting_started/3.5.shaders_exercise2/shaders_exercise2.cpp) 。
3.  使用 `out` 关键字将顶点位置输出到片段着色器，并将片段的颜色设置为等于该顶点位置（注意顶点位置值是如何在三角形内插值的）。完成此操作后，尝试回答以下问题：为什么三角形的左下角是黑色的？： [解决方案](https://learnopengl.com/code_viewer_gh.php?code=src/1.getting_started/3.6.shaders_exercise3/shaders_exercise3.cpp) 。