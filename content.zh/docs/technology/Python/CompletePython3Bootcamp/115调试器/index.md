---
title: "115调试器"
description: "115调试器"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-26T16:42:29+08:00
lastmod: 2026-09-26T16:42:29+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
> Python自带了一个内置的调试器

> 在.py文件中测试或者在同一个jupyter表格中填写，我在ipython中没法达到调试效果（看不到xyz的值）


```bash
╭─ ~/python_test/mydir115 main ?1                                              Py ly
╰─❯ cat mypy.py
import pdb
x=[1,2,3]
y=2
z=3
result_one=y+z
pdb.set_trace()
result_two=x+z

╭─ ~/python_test/mydir115 main ?1                                              Py ly
╰─❯ python mypy.py
> /home/ly/python_test/mydir115/mypy.py(7)<module>()
-> result_two=x+z
(Pdb) x
[1, 2, 3]
(Pdb) y
2
(Pdb) z
3
(Pdb) n
TypeError: can only concatenate list (not "int") to list
> /home/ly/python_test/mydir115/mypy.py(7)<module>()
-> result_two=x+z
(Pdb) n
--Return--
> /home/ly/python_test/mydir115/mypy.py(7)<module>()->None
-> result_two=x+z
(Pdb) n
Traceback (most recent call last):
  File "/home/ly/python_test/mydir115/mypy.py", line 7, in <module>
--Call--
> <frozen codecs>(309)__init__()
(Pdb) n
> <frozen codecs>(310)__init__()
(Pdb) q
TypeError: can only concatenate list (not "int") to list

```

| 命令         | 缩写  | 作用                    |
| ---------- | --- | --------------------- |
| `continue` | `c` | 继续运行，直到下一个断点或程序结束     |
| `next`     | `n` | 单步执行当前函数的下一行（不进入函数内部） |
| `step`     | `s` | 单步执行，并进入调用的函数内部       |
| `return`   | `r` | 继续运行，直到当前函数返回         |
| `quit`     | `q` | 退出调试，终止程序             |
| `where`    | `w` | 查看当前调用栈               |
| `up`       | `u` | 切换到上一层调用栈             |
| `down`     | `d` | 切换到下一层调用栈             |
| `list`     | `l` | 查看附近代码                |
| `print`    | `p` | 打印变量                  |

> 如果变量名也为n,c,s，应该使用`p c`这样否则直接用`c`会继续执行

```python
╭─ ~/python_test/mydir115 main ?1                                              Py ly
╰─❯ cat mypy.py
import pdb
x=[1,2,3]
y=2
z=3
result_one=y+z
pdb.set_trace()
result_two=x+z

╭─ ~/python_test/mydir115 main ?1                                              Py ly
╰─❯ python mypy.py
> /home/ly/python_test/mydir115/mypy.py(7)<module>()
-> result_two=x+z
(Pdb) x
[1, 2, 3]
(Pdb) y
2
(Pdb) z
3
(Pdb) n
TypeError: can only concatenate list (not "int") to list
> /home/ly/python_test/mydir115/mypy.py(7)<module>()
-> result_two=x+z
(Pdb) n
--Return--
> /home/ly/python_test/mydir115/mypy.py(7)<module>()->None
-> result_two=x+z
(Pdb) n
Traceback (most recent call last):
  File "/home/ly/python_test/mydir115/mypy.py", line 7, in <module>
--Call--
> <frozen codecs>(309)__init__()
(Pdb) n
> <frozen codecs>(310)__init__()
(Pdb) q
TypeError: can only concatenate list (not "int") to list
```

> 如上，出错后，n 不是“忽略错误继续下一行”，它只是“执行下一步”。异常没有被捕获时，没有下一行可以执行，Python会开始退出调用栈，pdb因此会看到一些内部 frame。


