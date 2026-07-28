---
title: 13vs用于c++项目的最佳实践
description: 13vs用于c++项目的最佳实践
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2025-12-20T16:08:08+08:00
lastmod: 2025-12-20T16:08:08+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
***vs用于c++项目的最佳实践***  

# 创建新项目

![](img/ly-20251220171552364.png)

解决方案下有项目  
 
 > MySolusion.sln是解决方案文件
 
![](img/ly-20251220171512084.png)  

项目下是源代码  

>Project.vcxproj 是项目相关文件
>Project.vcxproj.filters 是过滤器

![](img/ly-20251220171638015.png)  

过滤器决定了vs IDE打开该项目时的视图(实际中不存在文件夹)  

![](img/ly-20251220172459926.png)  

# 显示所有文件

显示磁盘目录下的所有文件  

![](img/ly-20251220180714438.png)  

移动文件位置  

![](img/ly-20251220182103808.png)  

```cpp
#include <iostream>
int main() {
	std::cout << "Hello World!" << std::endl;
	std::cin.get();
}
```

如图，中间文件(.obj)是放在项目文件夹里  

![](img/ly-20251220182411767.png)  

项目编译后生成的可执行文件放在（总的）解决方案文件夹下  

![](img/ly-20251220182451084.png)  

由来  

![](img/ly-20251220182725107.png)

`$(Platform)\$(Configuration)\`，即 `x64\Debug` 文件夹结构的由来  

# 修改配置

OutputDirectory: `$(SolutionDir)bin\$(Platform)\$(Configuration)\`    

> 如果解决方案有多个项目，如果构建DLL文件或者其他需要的东西，我们需要这些在同一个文件夹中（而不用深入每个项目的文件夹）

IntermediateDirectory: `$(SolutionDir)bin\intermediates\$(Platform)\$(Configuration)\`  

~~这里建议加上项目名，避免中间文件冲突(覆盖) `$(SolutionDir)bin\intermediates\$(ProjectName)\$(Platform)\$(Configuration)\`~~

![](img/ly-20251220185019820.png)  

之后右键项目-clean Solution

> 查看变量值  
> 
> ![](img/ly-20251220185324170.png)
> ![](img/ly-20251220185302696.png)
## 清理项目

解决方案下有一个项目  

![](img/ly-20251220184230313.png)  

项目下有过滤器及src文件夹  

![](img/ly-20251220184206453.png)

源代码在src文件夹中  

![](img/ly-20251220184257801.png)  


# 编译

![](img/ly-20251220184742527.png)  

![](img/ly-20251220184806581.png)  

![](img/ly-20251220184824789.png)  




