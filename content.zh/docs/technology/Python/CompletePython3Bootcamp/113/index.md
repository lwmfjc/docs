---
title: "113"
description: "113"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-25T09:59:03+08:00
lastmod: 2026-09-25T09:59:03+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# Datetime

# 基本使用

```python
In [2]: import datetime

#24小时制
In [3]:  #time(小时[,分钟[,秒[,毫秒[,时区]]]])

In [4]: mytime=datetime.time()

In [6]: mytime
Out[6]: datetime.time(0, 0)

In [7]: mytime=datetime.time(2,20)

In [8]: mytime
Out[8]: datetime.time(2, 20)

In [9]: print(mytime)
02:20:00

In [10]: mytime=datetime.time(14,20)

In [11]: print(mytime)
14:20:00

In [16]: mytime.minute
Out[16]: 20

In [17]: mytime.hour
Out[17]: 14

In [19]: mytime=datetime.time(13,20,1,20)

In [20]: print(mytime)
13:20:01.000020

#datetime#只包含时间，不包含日期
In [21]: type(mytime)
Out[21]: datetime.time
```
