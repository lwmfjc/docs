---
title: "14"
description: "14"
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2025-12-20T18:55:20+08:00
lastmod: 2025-12-20T18:55:20+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
***循环***

# for
当需要执行某些操作多次时  

```cpp
	for (int i = 0; i < 5; i = i + 1) {
		Log("Hello World");
	}
```

1. 先创建变量i(为零)
2. 然后检查i<5，是的话执行下面代码块(否则退出)
3. 然后i=i+1
4. 然后再检查i<5，是的话执行下面代码块(否则退出)
5. 3->4->3->4 反复循环直到退出

> i的作用域仅限于for代码块  
> 
> ![](img/ly-20251221112821557.png)  

上述代码也可改为  

```cpp
	int i = 0;
	for (; i < 5; ) {
		Log("Hello World");
		i = i + 1;
	}
```

或者  

```cpp
	int i = 0;
	bool condition = true;
	for (; condition; ) {
		Log("Hello World");
		i = i + 1;
		if (!(i < 5))
			condition = false;
	}
```

死循环  
```cpp
for(;;)
{
	
}
```

# while

基本上可以和for语句互转。但是如果有已经存在的条件，优先使用while  

```cpp

	int i = 0;
	while (i < 5) {
		Log("Hello World");
		i++;
	}
```

# do while

```cpp
//执行前先判断
bool condition = false;
while (condition)
{

}

//至少执行一次
do
{

} while (condition);
```

# 控制流
```cpp
for (int i = 0; i < 2; i++)
{

	std::cout << "i" << i << "-start" << std::endl; 
	for (int j = 0; j < 2; j++) {
		 
		std::cout << "j" << j << "-start" << std::endl;
		continue; //break;//;

		std::cout << "j" << j << "-end" << std::endl;
	}

	std::cout << "i" << i << "-end" << std::endl; 
}
```

![](img/ly-20251222222743448.png)  

continue，break，return  


- continue，跳过当前循环的剩余部分，并继续循环（下图中红色部分剔除）  
  
  ![](img/ly-20251222223036735.png)    
  
- break，跳过当前循环的剩余部分，并结束当前循环  （下图中红色部分剔除）  
  
  ![](img/ly-20251222223415111.png)  
- return ，直接退出函数  




