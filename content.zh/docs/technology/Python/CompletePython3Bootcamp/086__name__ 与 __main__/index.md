---
title: "086__name__ 与 __main__"
description: "086__name__ 与 __main__"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-21T19:58:43+08:00
lastmod: 2026-09-21T19:58:43+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
当你开始查看别人编写的大型py脚本时，经常会在最底部看到这样一行神秘的代码：`if __name__ == "__main"": `  ~~当你从模块导入时，你可能想知道模块的函数是被当做导入使用，还是你在使用该模块的原始py文件~~   

```python
╭─ ~/mydir2
╰─❯ python one.py
hello
run this py script direct

╭─ ~/mydir2
╰─❯ cat one.py
print('hello')

#说明目前正在直接运行这个.py脚本
if __name__ == "__main__":
        print("run this py script direct")
```

> 完整例子

```bash
╭─ ~/mydir2
╰─❯ cat one.py
def func():
        print("FUNC() IN ONE.PY")
print("TOP LEVEL IN ONE.PY")

if __name__ == '__main__':
        print('ONE.PY is being run directly!')
else: #一般不需要这个
        print('ONE.PY HAS been imported!')

╭─ ~/mydir2
╰─❯ cat two.py
import one

print("TOP LEVEL IN TWO.PY")
one.func()

if __name__ == '__main__':
        print('one.py is being run directly!')
else:
        print('one.py has been imported!')

╭─ ~/mydir2
╰─❯ python two.py
TOP LEVEL IN ONE.PY
ONE.PY HAS been imported!
TOP LEVEL IN TWO.PY
FUNC() IN ONE.PY
one.py is being run directly!
```