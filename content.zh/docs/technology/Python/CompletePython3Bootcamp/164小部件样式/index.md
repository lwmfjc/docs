---
title: "164小部件样式"
description: "164小部件样式"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-30T14:16:47+08:00
lastmod: 2026-09-30T14:16:47+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
> 接下来会假设你对HTML或者CSS中一些了解

```python
#显示一个普通滑块
import ipywidgets as widgets
from IPython.display import display

w = widgets.IntSlider()
display(w)
```

![](img/ly-20260930141923833.png)

```python
w.layout.margin = 'auto'
w.layout.height = '75px'
```

![](img/ly-20260930141949108.png)  
```python
#新滑块
x = widgets.IntSlider(value=15,description='New slider')
display(x)
```

![](img/ly-20260930142128697.png)

```python
#让x滑块与w的滑块布局一致
x.layout = w.layout
```

![](img/ly-20260930142048987.png)

预设样式，包括Bootstrap，包括primary,success,info,warning,danger等  

```python
import ipywidgets as widgets

widgets.Button(description='Ordinary Button', button_style='')
```

```python
widgets.Button(description='Danger Button', button_style='danger')
```

![](img/ly-20260930142247876.png)

# style 

```python
b1 = widgets.Button(description='Custom color')
b1.style.button_color = 'lightgreen'
b1
```

![](img/ly-20260930142349054.png)  

```python
b1.style.keys

['_model_module',
 '_model_module_version',
 '_model_name',
 '_view_count',
 '_view_module',
 '_view_module_version',
 '_view_name',
 'button_color',
 'font_family',
 'font_size',
 'font_style',
 'font_variant',
 'font_weight',
 'text_color',
 'text_decoration']
```

```python
#使用其他组件的样式
b2 = widgets.Button()
b2.style = b1.style
b2
```

![](img/ly-20260930142445213.png)

```python
s1 = widgets.IntSlider(description='Blue handle')
s1.style.handle_color = 'lightblue'
s1
```

![](img/ly-20260930142514248.png)  

