---
title: "163可用小部件列表"
description: "163可用小部件列表"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-30T13:37:11+08:00
lastmod: 2026-09-30T13:37:11+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
```python
import ipywidgets as widgets

# Show all available widgets!
for item in widgets.Widget.widget_types.items():
    print(item[0][2][:-5])
#=========out=================







import ipywidgets as widgets

# Show all available widgets!
for item in widgets.Widget.widget_types.items():
    print(item[0][2][:-5])
Layout
Accordion
Audio
BoundedFloatText
BoundedIntText
Box
Button
ButtonStyle
Checkbox
CheckboxStyle
ColorPicker
ColorsInput
Combobox
ControllerAxis
ControllerButton
Controller
DOMWidget
DatePicker
Datetime
DescriptionStyle
DirectionalLink
Dropdown
FileUpload
FloatLogSlider
FloatProgress
FloatRangeSlider
FloatSlider
FloatText
FloatsInput
GridBox
HBox
HTMLMath
HTMLMathStyle
HTML
HTMLStyle
Image
IntProgress
IntRangeSlider
IntSlider
IntText
IntsInput
Label
LabelStyle
Link
NaiveDatetime
Password
Play
ProgressStyle
RadioButtons
Select
SelectMultiple
SelectionRangeSlider
SelectionSlider
SliderStyle
Stack
Tab
TagsInput
Text
TextStyle
Textarea
Time
ToggleButton
ToggleButtonStyle
ToggleButtons
ToggleButtonsStyle
VBox
Valid
Video
Output

```

```python
widgets.IntSlider(
    value=7,
    min=0,
    max=10,
    step=1,
    description='Test:',
    disabled=False,
    continuous_update=False,
    orientation='horizontal',
    readout=True,
    readout_format='d'
)
```

![](img/ly-20260930135104512.png)  

```python
widgets.FloatSlider(
    value=7.5,
    min=0,
    max=10.0,
    step=0.1,
    description='Test:',
    disabled=False,
    continuous_update=False,
    orientation='horizontal',
    readout=True,
    readout_format='.1f'
)
```

![](img/ly-20260930135211756.png)  

```python
#垂直显示
widgets.FloatSlider(
    value=7.5,
    min=0,
    max=10.0,
    step=0.1,
    description='Test:',
    disabled=False,
    continuous_update=False,
    orientation='vertical',
    readout=True,
    readout_format='.1f'
)
```

![](img/ly-20260930135256113.png)  

```python
#范围滑块
widgets.IntRangeSlider(
    value=[5,7],
    min=0,
    max=10,
    step=1,
    description='Test:',
    disabled=False,
    continuous_update=False,
    orientation='horizontal',
    readout=True,
    readout_format='d'
)
```

![](img/ly-20260930135403757.png)

```python
widgets.IntProgress(
    value=7,
    min=0,
    max=10,
    step=1,
    description='Loading:',
    bar_style='',#'success','info','warning','danger' or ''
    orientation='horizontal'
)
```

![](img/ly-20260930135618386.png)  

![](img/ly-20260930135720718.png)  

```python
widgets.FloatProgress(
    value=7.5,
    min=0,
    max=10.0,
    step=0.1,
    description='Loading:',
    bar_style='info',
    orientation='horizontal'
)
```

![](img/ly-20260930140303634.png)  

```python
#有界整数
widgets.BoundedIntText(
    value=7,
    min=0,
    max=10,
    step=1,
    description='Text:',
    disabled=False
)
```

![](img/ly-20260930140353112.png)  

```python
#有界浮点数
widgets.BoundedFloatText(
    value=7.5,
    min=0,
    max=10.0,
    step=0.1,
    description='Text:',
    disabled=False
)
```

![](img/ly-20260930140437245.png)  

```python
#普通整数
widgets.IntText(
    value=7,
    description='Any:',
    disabled=False
)

```

![](img/ly-20260930140553196.png)  

```python
#普通浮点数
widgets.FloatText(
    value=7.5,
    description='Any:',
    disabled=False
)
```

![](img/ly-20260930140624622.png)  

```python
#布尔组件
widgets.ToggleButton(
    value=False,
    description='Click me',
    disabled=False,
    button_style='', # 'success', 'info', 'warning', 'danger' or ''
    tooltip='Description',
    icon='check'
)
```

![](img/ly-20260930140658144.png)  

```python
widgets.ToggleButton(
    value=False,
    description='Click me',
    disabled=False,
    button_style='success', # 'success', 'info', 'warning', 'danger' or ''
    tooltip='Description',
    icon='check'
)
```

![](img/ly-20260930140736553.png)  

```python
#勾选框
widgets.Checkbox(
    value=False,
    description='Check me',
    disabled=False
)
```

![](img/ly-20260930140808137.png)  

```python
#无法交互，只显示是否有效
widgets.Valid(
    value=False,
    description='Valid!',
)
```

![](img/ly-20260930140838774.png)  

```python
#指定数值选择
widgets.Dropdown(
    options=['1', '2', '3'],
    value='2',
    description='Number:',
    disabled=False,
)
```

![](img/ly-20260930140921117.png)  

```python
#带值的下拉
widgets.Dropdown(
    options={'One': 1, 'Two': 2, 'Three': 3},
    value=2,
    description='Number:',
)
```

![](img/ly-20260930140956994.png)  

```python
widgets.RadioButtons(
    options=['pepperoni', 'pineapple', 'anchovies'],
    # value='pineapple',
    description='Pizza topping:',
    disabled=False
)
```

![](img/ly-20260930141029209.png)  

```python
widgets.Select(
    options=['Linux', 'Windows', 'OSX'],
    value='OSX',
    # rows=10,
    description='OS:',
    disabled=False
)

```

![](img/ly-20260930141049942.png)

```python
#移动时有不同的选项
widgets.SelectionSlider(
    options=['scrambled', 'sunny side up', 'poached', 'over easy'],
    value='sunny side up',
    description='I like my eggs ...',
    disabled=False,
    continuous_update=False,
    orientation='horizontal',
    readout=True
)
```

![](img/ly-20260930141154473.png)

```python
#切换按钮
widgets.ToggleButtons(
    options=['Slow', 'Regular', 'Fast'],
    description='Speed:',
    disabled=False,
    button_style='', # 'success', 'info', 'warning', 'danger' or ''
    tooltips=['Description of slow', 'Description of regular', 'Description of fast'],
    # icons=['check'] * 3
)
```

![](img/ly-20260930141250898.png)  

```python
#多选
widgets.SelectMultiple(
    options=['Apples', 'Oranges', 'Pears'],
    value=['Oranges'],
    # rows=10,
    description='Fruits',
    disabled=False
)
```

![](img/ly-20260930141311189.png)  

```python
#字符串文本
widgets.Text(
    value='Hello World',
    placeholder='Type something',
    description='String:',
    disabled=False
)
```

![](img/ly-20260930141348986.png)  

```python
#多行文本
widgets.Textarea(
    value='Hello World',
    placeholder='Type something',
    description='String:',
    disabled=False
)
```

![](img/ly-20260930141425977.png)  

```python
#标签
widgets.HBox([widgets.Label(value="The $m$ in $E=mc^2$:"), widgets.FloatSlider()])

```

![](img/ly-20260930141458169.png)  

```python
widgets.HTML(
    value="Hello <b>World</b>",
    placeholder='Some HTML',
    description='Some HTML',
)
```

![](img/ly-20260930141514506.png)

```python
#HTML Math
widgets.HTMLMath(
    value=r"Some math and <i>HTML</i>: \(x^2\) and $$\frac{x+1}{x-1}$$",
    placeholder='Some HTML',
    description='Some HTML',
)

```

![](img/ly-20260930141542139.png)  

```python
#图片
file = open("images/WidgetArch.png", "rb")
image = file.read()
widgets.Image(
    value=image,
    format='png',
    width=300,
    height=400,
)
```

```python
#按钮
widgets.Button(
    description='Click me',
    disabled=False,
    button_style='', # 'success', 'info', 'warning', 'danger' or ''
    tooltip='Click me',
    icon='check'
)
```