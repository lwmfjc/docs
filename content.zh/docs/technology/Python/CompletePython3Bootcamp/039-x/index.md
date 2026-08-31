---
title: 039-x
description: 039-x
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-08-31T10:05:54+08:00
lastmod: 2026-08-31T10:05:54+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# if,elif,else

- 控制流：只在需要时才执行代码
- 靠缩进控制层级

```shell
if some_condition:
	# method1
	# method2
elif some_other_condition:
	#method3
	#method4
else:
	#method5
	#method6
#method7
```

- 所有处于if下的==*缩进*==层级 ~~method1,method2~~ 的代码，只有在条件 ~~some_condition~~ 为真时才会执行  
- method7永远都会执行，而其他的则依据条件而论

```shell
>>> a=3;b=4;
>>> a
3
>>> b
4
>>> if a<b:
...     print('a<b')
... elif a==5:
...     print('a=5')
... else:
...     print('other')
... print('hello world')
... 
a<b
hello world
>>> a=5;b=2;
>>> if a<b:
...     print('a<b')
... elif a==5:
...     print('a=5')
... else:
...     print('other')
... print('hello world')
... 
a=5
hello world
```