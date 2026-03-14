---
title: 03HelloWindow
description: 03HelloWindow
categories:
  - 学习
tags:
  - learnopengl
  - opengl
date: 2026-03-13T21:44:30+08:00
lastmod: 2026-03-13T21:44:30+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# Hello，Window

我们来看看能不能让 GLFW 运行起来。首先，创建一个 `.cpp` 文件，并在新创建的文件顶部添加以下包含语句。

```cpp
#include <glad/glad.h>
#include <GLFW/glfw3.h>
```

请务必在引入 GLFW 之前引入 GLAD。GLAD 的头文件包含了后台所需的 OpenGL 头文件（例如 `GL/gl.h` ），因此请确保在其他需要 OpenGL 的头文件（例如 GLFW）之前引入 GLAD。

接下来，我们创建主函数，并在其中实例化 GLFW 窗口：

```scss
int main()
{
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    //glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
  
    return 0;
}
```

在主函数中，我们首先使用 \`glfwInit\` 初始化 GLFW，之后可以使用 \`glfwWindowHint\` 配置 GLFW。\`glfwWindowHint\` 的第一个参数指定要配置的选项，我们可以从一个以 `GLFW_` 为前缀的枚举列表中选择。第二个参数是一个整数，用于设置选项的值。所有可用选项及其对应值的列表可以在 [GLFW 的窗口处理](http://www.glfw.org/docs/latest/window.html#window_hints)文档中找到。如果您现在尝试运行应用程序并出现大量_未定义引用_错误，则表示您没有成功链接 GLFW 库。

由于本书重点介绍 OpenGL 3.3 版本，我们需要告知 GLFW 我们要使用的 OpenGL 版本为 3.3。这样，GLFW 在创建 OpenGL 上下文时就能做出正确的配置。这确保了当用户没有安装正确的 OpenGL 版本时，GLFW 不会运行。我们将主版本号和次版本号都设置为 `3` 此外，我们还告知 GLFW 我们要==显式使用核心配置文件。使用核心配置文件意味着我们将获得 OpenGL 功能的一个较小子集，而不会使用我们不再需要的向后兼容功能。==请注意，在 macOS 系统上，您需要在初始化代码中添加 `glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);` 才能使其生效。

请确保您的系统/硬件上已安装 OpenGL 3.3 或更高版本，否则应用程序可能会崩溃或显示未定义行为。要查找计算机上的 OpenGL 版本，请在 Linux 系统上运行 **\`glxinfo\`** 命令，或在 Windows 系统上使用 [OpenGL Extension Viewer](http://download.cnet.com/OpenGL-Extensions-Viewer/3000-18487_4-34442.html) 等实用程序。如果您的系统支持的版本较低，请检查您的显卡是否支持 OpenGL 3.3 或更高版本（否则说明显卡版本过旧），并/或更新您的显卡驱动程序。  

```cpp
//我在代码中添加了这些代码得到了版本号（以下代码必须在初始化 GLAD后才能用）
const GLubyte* renderer = glGetString(GL_RENDERER); // 获取显卡名称
const GLubyte* version = glGetString(GL_VERSION);   // 获取 OpenGL 版本
std::cout << "Renderer: " << renderer << std::endl;
std::cout << "OpenGL version supported: " << version << std::endl;
//Renderer: AMD Radeon(TM) Vega 8 Graphics
//OpenGL version supported : 3.3.0 Core Profile Context 23.19.12.02.240618
```

接下来，我们需要创建一个窗口对象。这个窗口对象保存了所有窗口数据，GLFW 的大多数其他函数都需要用到它。

```cpp
GLFWwindow* window = glfwCreateWindow(800, 600, "LearnOpenGL", NULL, NULL);
if (window == NULL)
{
    std::cout << "Failed to create GLFW window" << std::endl;
    glfwTerminate();
    return -1;
}
glfwMakeContextCurrent(window);
```

\`glfwCreateWindow\` 函数的前两个参数分别是窗口的宽度和高度。第三个参数允许我们为窗口命名；目前我们将其命名为 `"LearnOpenGL"` ，但您可以随意命名。我们可以忽略最后两个参数。该函数返回一个 \`GLFWwindow\` 对象，我们稍后会在其他 GLFW 操作中用到它。之后，我们告诉 GLFW 将窗口的上下文设置为当前线程的主上下文。

# GLAD

上一章我们提到，GLAD 管理 OpenGL 的函数指针，因此我们需要在调用任何 OpenGL 函数之前初始化 GLAD：

```cpp
if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))
{
    std::cout << "Failed to initialize GLAD" << std::endl;
    return -1;
}
```

我们向 GLAD 传递一个函数，用于加载 OpenGL 函数指针的地址，该地址与操作系统相关。GLFW 则提供 glfwGetProcAddress 函数，该函数根据我们编译的目标操作系统定义正确的函数。

> GLAD: “我是 GLAD，我准备好了要给成千上万个 OpenGL 函数找地址了！但我不知道怎么跟这个操作系统（比如 Windows 11）开口要地址。”
> 
> 你（代码）: “别担心，GLAD。我把 GLFW 里的那个‘查号专家’ glfwGetProcAddress 介绍给你。你拿着它去查就行。”
> 
> GLAD: “太好了！那我开始干活了： 
> 拿着 glfwGetProcAddress 问：‘glClear 的地址在哪？’ -> 填入地址。
> 拿着 glfwGetProcAddress 问：‘glDrawArrays 的地址在哪？’ -> 填入地址。
> ...（重复几百次）...”
> GLAD: “报告！所有地址都填好了，初始化成功！”

# 视口

在开始渲染之前，我们还需要做最后一件事。我们需要==告诉 OpenGL 渲染窗口的大小==，以便 OpenGL 知道如何相对于窗口显示数据和坐标。我们可以通过 glViewport 函数设置这些_尺寸_ ：

```scss
glViewport(0, 0, 800, 600);
```

glViewport 的前两个参数设置窗口左下角的位置。第三个和第四个参数设置渲染窗口的宽度和高度（以像素为单位），我们将其设置为与 GLFW 的窗口大小相同。

*我们实际上可以将视口尺寸设置为小于 GLFW 尺寸的值；这样，所有 OpenGL 渲染都将显示在较小的窗口中，例如，我们可以在 OpenGL 视口之外显示其他元素。*

在后台，OpenGL 使用通过 glViewport 指定的数据，将处理后的二维坐标转换为屏幕上的坐标。例如，处理后的点 `(-0.5,0.5)` 最终会被映射到屏幕坐标系中的 `(200,450)` 。需要注意的是，OpenGL 中处理后的坐标范围在 -1 到 1 之间，因此我们实际上是将 (-1 到 1) 的范围映射到 (0, 800) 和 (0, 600)。

然而，当用户调整窗口大小时，视口也应该随之调整。我们可以==为窗口注册一个回调函数，该函数会在每次窗口大小调整时被调用==。这个调整大小回调函数的原型如下：

```cpp
void framebuffer_size_callback(GLFWwindow* window, int width, int height);
```

帧缓冲区大小函数以 GLFW 窗口作为第一个参数，后两个整数分别表示新的窗口尺寸。==每当窗口大小发生变化时，GLFW 都会调用此函数并填充相应的参数供您处理==。

```cpp
void framebuffer_size_callback(GLFWwindow* window, int width, int height)
{
    glViewport(0, 0, width, height);
}
```

我们需要通过注册来告诉 GLFW 我们希望在每次窗口大小调整时调用此函数：

```scss
glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
```

窗口首次显示时，\`framebuffer\_size\_callback\` 函数也会被调用，并传入最终的窗口尺寸。对于 Retina 显示屏， 宽度和高度最终会比原始输入值大得多。

我们可以设置许多回调函数来注册我们自己的函数。例如，我们可以创建一个回调函数来处理操纵杆输入的变化、处理错误信息等等。我们在创建窗口之后、渲染循环开始之前注册这些回调函数。

# 准备好你的引擎

我们不希望应用程序绘制完一张图片后就立即退出并关闭窗口。我们希望应用程序持续绘制图像并处理用户输入，直到程序被明确告知停止为止。因此，我们需要创建一个 while 循环，我们称之为==渲染循环，它会一直运行，直到我们告诉 GLFW 停止为止==。以下代码展示了一个非常简单的渲染循环：

```scss
while(!glfwWindowShouldClose(window))
{
    glfwSwapBuffers(window);
    glfwPollEvents();    
}
```

glfwWindowShouldClose 函数会在每次循环迭代开始时检查 GLFW 是否已被指示关闭。如果已被指示关闭，则该函数返回 `true` ，渲染循环停止运行，之后我们就可以关闭应用程序了。  
glfwPollEvents 函数检查是否有任何事件被触发（例如键盘输入或鼠标移动事件），==更新窗口状态，并调用相应的函数（我们可以通过回调方法注册这些函数）==。 glfwSwapBuffers 会==交换在本次渲染迭代期间用于渲染的颜色缓冲区==（一个大的 2D 缓冲区，其中包含 GLFW 窗口中每个像素的颜色值），并将其作为输出显示在屏幕上。

## 双缓冲层  

当应用程序使用==单个缓冲区==进行绘制时，生成的图像可能会出现闪烁问题。这是因为最终输出图像并非瞬间绘制完成，而是==逐像素 ~~就是一个个小方格~~ 绘制，通常是*从左到右、从上到下*==。由于图像在渲染过程中并未立即显示给用户，因此结果可能包含瑕疵。为了避免这些问题，窗口应用程序采用双缓冲进行渲染。 ***前***缓冲区包含==最终显示在屏幕上的输出图像==，而所有渲染命令都绘制到***后***缓冲区。==一旦所有渲染命令完成，我们就将后缓冲区的***内容切换***到前缓冲区==，这样图像就可以在不进行渲染的情况下显示，从而消除上述所有瑕疵。

# 最后一件事

==渲染循环结束后，我们需要彻底清理/删除所有已分配的 GLFW 资源==。这可以通过在主函数末尾调用的 glfwTerminate 函数来实现。

```kotlin
glfwTerminate();
return 0;
```

这将清理所有资源并正确退出应用程序。现在尝试编译您的应用程序，如果一切顺利，您应该会看到以下输出：

![](img/ly-20260314072714137.png)

如果显示的是一张非常单调乏味的黑色图片，那就对了！如果显示的不是正确的图片，或者对各个部分的组合方式感到困惑，请点击 [此处](https://learnopengl.com/code_viewer_gh.php?code=src/1.getting_started/1.1.hello_window/hello_window.cpp)查看完整的源代码（如果代码开始闪烁不同的颜色，请继续阅读）。

如果编译应用程序时遇到问题，请首先确保所有链接器选项都已正确设置，并且已在 IDE 中正确包含正确的目录（如上一章所述）。此外，请确保代码正确；您可以通过将其与完整源代码进行比较来验证。

# 输入

我们还希望在 GLFW 中实现某种形式的输入控制，这可以通过 GLFW 的几个输入函数来实现。我们将使用 GLFW 的 glfwGetKey 函数，==该函数接受窗口和按键作为输入。该函数返回当前按键是否被按下==。我们正在创建一个 processInput 函数来组织所有输入代码：

```javascript
void processInput(GLFWwindow *window)
{
    if(glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
}
```

这里我们==检查用户是否按下了 Esc 键（如果没有按下，glfwGetKey 返回 GLFW\_RELEASE ）。如果用户按下了 Esc 键，我们使用 glfwSetwindowShouldClose 将 GLFW 的 WindowShouldClose 属性设置为 `true` 来关闭 GLFW==。这样，主 `while` 循环的下一个条件检查就会失败，应用程序就会关闭。

然后，我们在渲染循环的每次迭代中调用 processInput：

```scss
while (!glfwWindowShouldClose(window))
{
    processInput(window);

    glfwSwapBuffers(window);
    glfwPollEvents();
}
```

这让我们能够轻松地检测特定的按键操作，并在每一帧都做出相应的反应。渲染循环的一次迭代通常被称为一帧。

# 渲染

我们希望将所有渲染命令都放在渲染循环中，因为我们希望在循环的每次迭代或帧中执行所有渲染命令。代码大致如下：

```scss
// render loop
while(!glfwWindowShouldClose(window))
{
    // input
    processInput(window);

    // rendering commands here
    ...

    // check and call events and swap the buffers
    glfwPollEvents();
    glfwSwapBuffers(window);
}
```

为了测试是否有效，我们需要用我们选择的颜色清空屏幕。我们希望==在帧开始时清空屏幕==。否则，我们仍然会看到上一帧的结果（这可能是你想要的效果，但通常情况下并非如此）。我们可以使用 \`glClear\` 函数清空屏幕的颜色缓冲区，该函数需要==传入缓冲区位来指定要清空的缓冲区==。我们可以设置的位包括 \`GL\_COLOR\_BUFFER\_BIT\` ~~颜色：看起来是什么颜色？~~  、 \`GL\_DEPTH\_BUFFER\_BIT\` ~~深度：谁在前面谁在后面？~~  和 \`GL\_STENCIL\_BUFFER\_BIT\` ~~模板：哪里可以画，哪里不行？~~  。==目前我们只关心颜色值，所以只清空颜色缓冲区==。

```scss
glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
glClear(GL_COLOR_BUFFER_BIT);
```

请注意，我们还使用 glClearColor 指定了清屏颜色。每当我们调用 glClear 并清空颜色缓冲区时，整个颜色缓冲区都会填充 glClearColor 配置的颜色。这将导致屏幕呈现深绿蓝色。

你可能还记得 _OpenGL_ 章节中讲到的，==glClearColor 函数是一个_状态设置_函数，而 glClear 是一个_状态使用_函数==，因为它使用当前状态来检索清除颜色。   

![](img/ly-20260314072823326.png)

该应用程序的完整源代码可以 [在这里](https://learnopengl.com/code_viewer_gh.php?code=src/1.getting_started/1.2.hello_window_clear/hello_window_clear.cpp)找到。

所以现在我们已经准备好用大量的渲染调用来填充渲染循环，但这要留到 [下一章再讲](https://learnopengl.com/Getting-started/Hello-Triangle) 。我想我们已经说得够多了。
# 附上自己写的代码及注释

```cpp
#ifdef LY_EP03
#include <glad/glad.h>
#include <GLFW/glfw3.h> 

#include <iostream>
#include <thread> // 包含 sleep_for
#include <chrono> // 包含时间单位

void processInput(GLFWwindow* window)
{
	/*
	检查用户是否按下了 Esc 键（如果没有按下，glfwGetKey 返回 GLFW\_RELEASE ）。如果用户按下了 Esc 键，我们使用 glfwSetwindowShouldClose 将 GLFW 的 WindowShouldClose 属性设置为 `true` 来关闭 GLFW
	*/
	if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
		glfwSetWindowShouldClose(window, true);
}


//该函数在窗口大小变化时回调，每当窗口大小发生变化时，GLFW 都会调用此函数并填充相应的参数供您处理
void framebuffer_size_callback(GLFWwindow* window, int width, int height)
{
	//告诉 OpenGL 渲染窗口的大小
	glViewport(0, 0, width, height);
}

int main()
{
	// 1. 初始化 GLFW
	glfwInit();
	//将主版本号和次版本号都设置为 `3` 
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);

	//显式使用核心配置文件。使用核心配置文件意味着我们将获得 OpenGL 功能的一个较小子集，而不会使用我们不再需要的向后兼容功能。
	//强制现代性：如果你不小心写了任何旧时代的函数（比如 glBegin），程序会直接报错或崩溃，而不是默默地运行。这能强制你养成正确的现代绘图习惯。

	//1. 删掉的是：那些由驱动程序自动帮你完成、但性能低下的“黑盒”功能。
	//2. 保留的是：那些能直接操作 GPU 硬件、让性能起飞的核心指令。
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

	//在 macOS 系统上需要额外添加这行才能生效
	//glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);


	// 2. 创建窗口对象
	//创建一个窗口对象。这个窗口对象保存了所有窗口数据，GLFW 的大多数其他函数都需要用到它。
	//窗口 (Window)：是由操作系统（Windows / macOS）管理的容器。它有标题栏、最小化按钮、边框。
	GLFWwindow* window = glfwCreateWindow(800, 600, "LearnOpenGL", NULL, NULL);
	if (window == NULL)
	{
		std::cout << "Failed to create GLFW window" << std::endl;
		glfwTerminate();
		return -1;
	}

	//真正存储 OpenGL 所有状态（比如我们之前聊的那个巨大的 struct OpenGL_Context）的，是隐藏在窗口背后的 上下文（Context）
	//告诉 GLFW 将窗口的上下文设置为当前线程的主上下文
	glfwMakeContextCurrent(window);


	//调用任何 OpenGL 函数之前初始化 GLAD
	//glfwGetProcAddress（获取函数地址）,属于 GLFW 库
	//gladLoadGLLoader(...)：属于 GLAD 库。
	//向 GLAD 传递一个函数，用于加载 OpenGL 函数指针的地址，该地址与操作系统相关
	if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))
	{
		std::cout << "Failed to initialize GLAD" << std::endl;
		return -1;
	}

	const GLubyte* renderer = glGetString(GL_RENDERER); // 获取显卡名称
	const GLubyte* version = glGetString(GL_VERSION);   // 获取 OpenGL 版本
	std::cout << "Renderer: " << renderer << std::endl;
	std::cout << "OpenGL version supported: " << version << std::endl;
	//Renderer: AMD Radeon(TM) Vega 8 Graphics
	//OpenGL version supported : 3.3.0 Core Profile Context 23.19.12.02.240618

	//视口 (Viewport)：是 OpenGL 实际绘图的区域。它存在于窗口内部。
	//重点：视口不一定要填满整个窗口。
	//glViewport(0, 0, 800, 600);

	// 注册 窗口大小改变的回调
	glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

	int i = 0;

	//1. 问：该下班（关窗口）了吗？
	while (!glfwWindowShouldClose(window))
	{//顺序原则：先取样（Poll），再处理（Input），后绘制（Render），末提交（Swap）

		//check and call events
		//这个函数负责处理所有的互动
		//它去操作系统那里询问：“刚才这 0.01 秒里，用户动鼠标了吗？按 ESC 键了吗；如果你之前注册过“按下 ESC 就关窗口”的函数，glfwPollEvents 发现你按了 ESC，就会立刻跳过去执行你的那个函数
		// 1. 查：刚才用户有没有搞什么小动作（按键、移动鼠标）？
		glfwPollEvents();


		//input
		//2.算：根据输入处理逻辑（Process Input / Update Logic）
		processInput(window);

		//这里稍微改下逻辑，验证了确实是双缓冲区处理图像
		if (i % 2 == 0)
		{
			i++;
			// 3. 画：清屏并执行渲染指令（Rendering）
			// 这里通常会写 glClear() 和 glDraw... (开始在“后台”画画)
			// rendering commands here
			//设置rgba值，20% 的红，30% 的绿，30% 的蓝，100%不透明
			glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
		}
		else
		{
			i--;
			//设置rgba值，30% 的红，20% 的绿，10% 的蓝，100%不透明
			glClearColor(0.3f, 0.2f, 0.1f, 1.0f);

		}

		//立刻把 GL_COLOR_BUFFER_BIT（颜色缓冲区）里所有的像素，全部涂成我刚才在 glClearColor 里指定的颜色
		glClear(GL_COLOR_BUFFER_BIT);

		//swap the buffers
		/*
	*单缓冲（坏处）：如果你直接在观众面前画，观众会看到你先
	  画背景，再画人物，最后上色。这在屏幕上会导致严重的闪烁，因为观众看到了“半成品”。
	* 双缓冲（glfwSwapBuffers）：
		* 后缓冲区 (Back Buffer)：这是隐藏在后台的画布。所
		  有的 glClear、glDraw... 都在这里偷偷进行。观众看不见。
		* 前缓冲区 (Front Buffer)：这是目前正在屏幕上显示的成品图。
		* glfwSwapBuffers 的动作：当你在后台画好了完整的一帧，这行代码会瞬间把“前台”和“后台”交换。观众看的是上一秒画好的，而你已经在准备下一秒的了。
*/
// 4. 喊：画好了！把画完的后台画布翻到前台给用户看！
		glfwSwapBuffers(window);

	}

	//渲染循环结束后，我们需要彻底清理 / 删除所有已分配的 GLFW 资源
	glfwTerminate();
	return 0;
}

#endif
```



