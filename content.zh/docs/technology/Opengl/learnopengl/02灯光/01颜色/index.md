---
title: 01颜色
description: 01颜色
categories:
  - 学习
tags:
  - opengl
  - learnopengl
date: 2026-05-07T11:30:58+08:00
lastmod: 2026-05-07T11:30:58+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 颜色

我们在前几章中简单地使用和处理了颜色，但从未对它们进行过正式的定义。在这里，我们将讨论颜色的概念，并为接下来的光照章节构建场景。

在现实世界中，颜色可以取任何已知的颜色值，每个物体都有其独特的颜色。而在数字世界中，我们需要将（无限的）真实颜色映射到（有限的）数字值，因此并非所有现实世界的颜色都能用数字方式表示。颜色通常使用 `red` 、 `green` 、 `blue` 三个分量进行数字表示，简写为 `RGB` 。通过对这三个值在 `[0,1]` 范围内进行不同的组合，我们几乎可以表示任何颜色。例如，要得到_珊瑚色_ ，我们可以定义一个颜色向量：

```css
glm::vec3 coral(1.0f, 0.5f, 0.31f);
```

我们在现实生活中看到的物体颜色并非它本身的颜色，而是物体反射的颜色。物体未吸收（反射）的颜色就是我们感知到的颜色。例如，太阳光被感知为白光，它是多种不同颜色混合而成的（如图所示）。如果我们用这种白光照射一个蓝色的玩具，它会吸收除蓝色以外的所有白色光。由于玩具不吸收蓝色光，所以蓝色光会被反射。这些反射光进入我们的眼睛，使我们觉得玩具是蓝色的。下图展示了一个珊瑚色玩具反射多种不同强度颜色的光：

![](https://learnopengl.com/img/lighting/light_reflection.png)

你可以看到，白色的阳光是由所有可见颜色组成的，物体吸收了其中的大部分颜色。它只反射那些代表物体颜色的颜色，而这些颜色的组合就构成了我们所感知到的颜色（在本例中是珊瑚色）。

从技术上讲，这有点复杂，但我们会在 PBR 章节中讨论这个问题。

这些颜色反射规则直接适用于图形领域。在 OpenGL 中定义光源时，我们需要给它赋予颜色。上一段中我们用了白色，所以光源也用白色。如果我们把光源的颜色值乘以物体的颜色值，得到的颜色就是物体的反射颜色（也就是它的感知颜色）。让我们再来看看之前的例子（这次用珊瑚色），看看如何在图形领域计算它的感知颜色。我们通过将光源颜色向量和物体颜色向量逐个分量相乘来得到结果颜色向量：

```cpp
glm::vec3 lightColor(1.0f, 1.0f, 1.0f);
glm::vec3 toyColor(1.0f, 0.5f, 0.31f);
glm::vec3 result = lightColor * toyColor; // = (1.0f, 0.5f, 0.31f);
```

我们可以看到，玩具的颜色 _吸收了_大部分白光，但根据其自身的色值，反射出几种红色、绿色和蓝色光。这模拟了现实生活中颜色的运作方式。因此，我们可以将物体的颜色定义为_它从光源反射的各种颜色分量的量_ 。那么，如果我们使用绿光会发生什么呢？

```cpp
glm::vec3 lightColor(0.0f, 1.0f, 0.0f);
glm::vec3 toyColor(1.0f, 0.5f, 0.31f);
glm::vec3 result = lightColor * toyColor; // = (0.0f, 0.5f, 0.0f);
```

正如我们所见，这个玩具本身不吸收或反射红光和蓝光。它吸收了光线中一半的绿色成分，但也反射了另一半绿色成分。因此，我们感知到的玩具颜色是深绿色。我们可以看到，如果使用绿光，只有绿色成分会被反射并被感知；红色和蓝色成分则无法被感知。结果，珊瑚物体突然变成了深绿色。让我们再用深橄榄绿色的光来做一个例子：

```cpp
glm::vec3 lightColor(0.33f, 0.42f, 0.18f);
glm::vec3 toyColor(1.0f, 0.5f, 0.31f);
glm::vec3 result = lightColor * toyColor; // = (0.33f, 0.21f, 0.06f);
```

正如你所看到的，我们可以使用不同的光色来给物体赋予有趣的颜色。玩转色彩并不难，可以尽情发挥创意。

好了，关于颜色就说到这里，让我们开始搭建一个可以进行实验的场景吧。

# 灯光场景

在接下来的章节中，我们将通过模拟真实世界的光照并大量运用色彩来创建有趣的视觉效果。由于现在我们将使用光源，因此我们需要将它们显示为场景中的视觉对象，并添加至少一个对象来模拟光照。

首先，我们需要一个用来照射物体的模型，我们将使用前几章中提到的那个著名的容器立方体。我们还需要一个光源模型来表示光源在 3D 场景中的位置。为了简单起见，我们也用一个立方体来表示光源（我们已经有了 [顶点数据，](https://learnopengl.com/code_viewer.php?code=getting-started/cube_vertices_pos) 对吧？）。

所以，填充顶点缓冲区对象、设置顶点属性指针等等这些操作，你现在应该都很熟悉了，我们就不再赘述了。如果你仍然不明白这些操作，我建议你先复习一下 [前面的章节](https://learnopengl.com/Getting-started/Hello-Triangle) ，如果可以的话，完成练习，然后再继续学习。

首先，我们需要一个顶点着色器来绘制容器。容器的顶点位置保持不变（尽管这次我们不需要纹理坐标），所以代码应该没什么变化。我们将使用上几章中顶点着色器的简化版本：

```csharp
#version 330 core
layout (location = 0) in vec3 aPos;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()
{
    gl_Position = projection * view * model * vec4(aPos, 1.0);
}
```

请确保更新顶点数据和属性指针以匹配新的顶点着色器（如果需要，实际上可以保持纹理数据和属性指针处于活动状态；我们只是现在没有使用它们）。

因为我们还要渲染一个光源立方体，所以我们需要专门为光源生成一个新的 VAO。我们可以使用同一个 VAO 渲染光源，然后对 模型矩阵进行一些光照位置变换，但在接下来的章节中，我们会频繁地更改容器对象的顶点数据和属性指针，我们不希望这些更改传播到光源对象（我们只关心光源立方体的顶点位置），所以我们将创建一个新的 VAO：

```scss
unsigned int lightVAO;
glGenVertexArrays(1, &lightVAO);
glBindVertexArray(lightVAO);
// we only need to bind to the VBO, the container's VBO's data already contains the data.
glBindBuffer(GL_ARRAY_BUFFER, VBO);
// set the vertex attribute 
glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
glEnableVertexAttribArray(0);
```

代码应该比较简单。现在我们已经创建了容器和光源立方体，只剩下一件事需要定义，那就是容器和光源的片段着色器：

```csharp
#version 330 core
out vec4 FragColor;
  
uniform vec3 objectColor;
uniform vec3 lightColor;

void main()
{
    FragColor = vec4(lightColor * objectColor, 1.0);
}
```

片段着色器接受来自 uniform 变量的对象颜色和光源颜色。这里，我们将光源颜色与对象（反射）颜色相乘，就像我们在本章开头讨论的那样。同样，这个着色器应该很容易理解。让我们用白光将对象的颜色设置为上一节中的珊瑚色：

```php
// don't forget to use the corresponding shader program first (to set the uniform)
lightingShader.use();
lightingShader.setVec3("objectColor", 1.0f, 0.5f, 0.31f);
lightingShader.setVec3("lightColor",  1.0f, 1.0f, 1.0f);
```

还有一点需要注意的是，当我们在后续章节中更新这些 _光照着色器_时，光源立方体也会受到影响，而这并非我们所期望的。我们不希望光源对象的颜色影响光照计算，而是希望光源与其他对象隔离。我们希望光源保持恒定的明亮颜色，不受其他颜色变化的影响（这样才能使光源立方体看起来确实是光源）。

为了实现这一点，我们需要创建第二组着色器来绘制光源立方体，这样就不会受到光照着色器任何更改的影响。顶点着色器与光照顶点着色器相同，因此您可以直接复制源代码。光源立方体的片段着色器通过在灯上定义恒定的白色来确保立方体的颜色保持明亮：

```csharp
#version 330 core
out vec4 FragColor;

void main()
{
    FragColor = vec4(1.0); // set all 4 vector values to 1.0
}
```

当我们想要渲染时，我们会使用刚刚定义的光照着色器来渲染容器对象（或可能还有许多其他对象）；而当我们想要绘制光源时，则会使用光源自身的着色器。在“光照”章节中，我们将逐步更新光照着色器，以慢慢实现更逼真的效果。

光源立方体的主要目的是显示光源的位置。我们通常会在场景中定义光源的位置，但这仅仅是一个没有视觉意义的位置。为了显示光源的实际位置，我们在光源所在的位置渲染一个立方体。我们使用光源立方体着色器渲染这个立方体，以确保无论场景的光照条件如何，立方体始终保持白色。

所以，我们声明一个全局 `vec3` 变量，它表示光源在世界坐标系中的位置：

```css
glm::vec3 lightPos(1.2f, 1.0f, 2.0f);
```

然后我们将光源立方体平移到光源位置，并缩小尺寸后再进行渲染：

```ini
model = glm::mat4(1.0f);
model = glm::translate(model, lightPos);
model = glm::scale(model, glm::vec3(0.2f));
```

最终生成的光源立方体的渲染代码应该如下所示：

```scss
lightCubeShader.use();
// set the model, view and projection matrix uniforms
[...]
// draw the light cube object
glBindVertexArray(lightCubeVAO);
glDrawArrays(GL_TRIANGLES, 0, 36);
```

将所有代码片段注入到相应位置后，即可得到一个干净的 OpenGL 应用程序，该应用程序已正确配置，可用于进行光照实验。如果一切编译成功，它应该如下所示：

![](https://learnopengl.com/img/lighting/colors_scene.png)

现在没什么特别的，但我保证接下来的章节会更有趣。

如果您难以找到所有代码片段在整个应用程序中的位置，请 [在此处](https://learnopengl.com/code_viewer_gh.php?code=src/2.lighting/1.colors/colors.cpp)查看源代码，并仔细阅读代码/注释。

现在我们已经对颜色有了相当多的了解，并且创建了一个用于试验光照的基本场景，我们可以进入 [下一章](https://learnopengl.com/Lighting/Basic-Lighting) ，真正的魔法将从这里开始。