---
title: "085"
description: "085"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-21T19:21:33+08:00
lastmod: 2026-09-21T19:21:33+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 模块与包

> 编写自己的模块与包

- 模块本质上就是你在另一个 .py 脚本中调用的 .py 脚本 ~~被调用的这个.py脚本成为模块~~ 。   
- 包是模块的集合。   
- 要让Python知道这一组.py脚本应该被视为一个完整的包，就需要在文件夹内放置一个名为`__init__.py` 的关键脚本  

## (单)模块

> 编写自己的模块，导入并使用它

```bash
╭─ ~/mydir
╰─❯ cat mymodule.py
def my_func():
        print("Hey I am in mymodel.py")


╭─ ~/mydir
╰─❯ cat myprogram.py
from mymodule import my_func

my_func()

╭─ ~/mydir
╰─❯ python myprogram.py
Hey I am in mymodel.py
```

## 包

- `__init__.py`这个文件告诉Python，这个目录有一堆模块，你可以用特定的语法来调用他们
    - 只要这个目录的子目录里还有`__init__.py`，那么子目录就可以用来创建更深的子包

> 目录结构

```bash
╭─ ~/mydir1
╰─❯ tree
.
├── MyMainPackage
│   ├── SubPackage
│   │   ├── __init__.py
│   │   └── mysubscript.py
│   ├── __init__.py
│   └── some_main_script.py
└── myprogram.py
```

> 两个`__init__.py`保持空内容即可 ~~但是两个文件必须存在~~ 

```bash
╭─ ~/mydir1
╰─❯ cat MyMainPackage/__init__.py

╭─ ~/mydir1
╰─❯ cat MyMainPackage/SubPackage/__init__.py

```

> 文件`some_main_script.py`和`mysubscript.py`分别编写一些函数

```bash
╭─ ~/mydir1
╰─❯ cat MyMainPackage/some_main_script.py
def report_main():
        print("Hey I am in some_main_script in main package")

╭─ ~/mydir1
╰─❯ cat MyMainPackage/SubPackage/mysubscript.py
def sub_report():
        print("Hey Im a function inside mysubscript")
```

> 主程序

```bash
╭─ ~/mydir1
╰─❯ cat myprogram.py
#从包中导入模块
from MyMainPackage import some_main_script
#从子包中导入模块
from MyMainPackage.SubPackage import mysubscript

some_main_script.report_main()
mysubscript.sub_report()
```

```bash
#运行主程序即可
╭─ ~/mydir1
╰─❯ python myprogram.py
Hey I am in some_main_script in main package
Hey Im a function inside mysubscript
```