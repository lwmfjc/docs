---
title: hugo进阶学习20-23
description: hugo进阶学习20-23
categories:
  - 学习
tags:
  - hugo 
date: 2024-12-10 15:54:58  
updated: 2024-12-10 16:06:47  
---
![](img/ly-20241212142130925.png)  

# DateFiles
```json  
{% raw %} 
{
  "classA":"json位置: data\\classes.json",
  "classA":{
    "master":"xiaoLi",
    "number":"05"
  },
  "classB":{
    "master":"aXiang",
    "number":"15"
  },
  "classC":{
    "master":"BaoCeng",
    "number":"20"
  }
}  
{% endraw %} 
```
模板代码  
``` html 
{% raw %} 
{{/* layouts\_default\single.html */}}
{{ define "main" }}
     {{ range .Site.Data.classes }}
          master:{{.master}}==number:{{.number}}<br>
     {{end}}
{{end}} 
{% endraw %} 
```

![](img/ly-20241212142131035.png)  
# PartialTemplates
## 传递全局范围
``` html 
{% raw %} 
{{/*layouts\partials\header.html*/}}
<h1>{{.Title}}</h1>
<p>{{.Date}}</p> 
{% endraw %} 
```

```  
{% raw %} 
{{/*layouts\_default\single.html*/}}
{{ define "main" }}
  {{ partial "header" . }}
  {{/*点.传递了当前文件的范围，代表了所有的范围，所有可以访问的变量*/}}
  <hr>
{{end}} 
{% endraw %} 
```
预览：  
![](img/ly-20241212142131117.png)  

## 传递字典
``` html 
{% raw %} 
{{/* layouts\partials\header.html */}}
{{ partial "header" (dict "myTitle" "myCustomTitle" "myDate" "myCustomDate" ) }}
{{/* partial "header" . 同一个partial只能在一个地方出现一次？这里会报错，不知道为啥*/}}
  <hr> 
{% endraw %} 
```
使用:  
``` html 
{% raw %} 
{{/*layouts\partials\header.html*/}}
<h1>{{.myTitle}}</h1>
<p>{{.myDate}}</p> 
{% endraw %} 
```

效果：  
![](img/ly-20241212142131191.png)  

# ShortCodeTemplate
## 效果图
![](img/ly-20241212142131266.png)  
## 记得先在a相关的template把 .Content 补上
## 代码片段的使用
``` markdown 
{% raw %} 
---
title: "This is A's title"
date: 2004-12-04T12:42:49+08:00
draft: true
author: "Mike"
color: "blue"
---

This is A.  
{{</*  myshortcode color="blue" */>}}
{{</*  myshortcode2 red  */>}}

{{</*  myshortcode-p  */>}}
  This is the test inside the shortcode tags..  

  sdf  
  
  d---end  
{{</*  /myshortcode-p  */>}}  
下面没有被渲染：  

{{</*  myshortcode-p  */>}}
  **bold text**
{{</*  /myshortcode-p  */>}}
下面被渲染了，但是没有被片段处理：  

{{%/* myshortcode-p  */%}}
  **bold text**xxx
{{%/* /myshortcode-p  */%}} 
{%/* endraw */%} 
```
## 代码片段的编写
### 等号键值对
``` html 
{% raw %} 
<!--layouts\shortcodes\myshortcode.html-->
<p style="color:{{.Get `color`}}">This is my shortcode text</p> 
{% endraw %} 
```
### 直接写值
``` html 
{% raw %} 
<!--layouts\shortcodes\myshortcode2.html-->
<p style="color:{{.Get 0}}">This is my shortcode text</p> 
{% endraw %} 
```
### 获取多行大量文字
``` html 
{% raw %} 
<!--layouts\shortcodes\myshortcode-p.html-->
<p style="background-color: yellow;">{{.Inner}}</p> 
{% endraw %} 
```

# 如何构建网站及托管

1. 使用```hugo server```运行并打开网站（平常测试）
2. 使用```hugo```生成静态网页文件夹```/public/``` ![](img/ly-20241212142131339.png) 
3. 把上面的/public/下的所有文件传到网络服务器即可
4. 进行第三步之前，得先把原先传到网络服务器上的```/public/```的内容清空