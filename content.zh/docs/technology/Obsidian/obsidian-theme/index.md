---
title: obsidian-theme
description: obsidian-theme
categories:
  - 学习
tags:
  - obsidian 
date: 2024-12-03 15:32:01  
updated: 2024-12-03 15:32:01  
---
# 主题推荐
1. Neumorphism-dark.json  
    ![](img/ly-20241212142158673.jpg)
2. Sunset-base64.json  ✔
   ![](img/ly-20241212142158832.jpg)
3. Obsidian-default-dark-alt  ✔
   ![](img/ly-20241212142158865.jpg)  
   4. Obsidian-default-light-alt 
      ![](img/ly-20241212142158906.jpg)
 
8. Neumorphism.json 
   ![](img/ly-20241212142158942.jpg)
12. eyefriendly  ✔
    ![](img/ly-20241212142158977.jpg)
13. boundy   ✔
    ![](img/ly-20241212142159017.jpg)
flexoki-light 
![](img/ly-20241212142159055.jpg)Borderless-light 
![](img/ly-20241212142159093.jpg)

# 关于obsidian主题border的背景图片设置  
配合StyleSettings，在StyleSettings的这里设置  
![](img/ly-20241212142159126.jpg)  
## 暂不明确
background中貌似存在转换规则，不是直接用url("")这个形式把图片base64放进来就可以了，目前觉得可能的转换规则  
```shell
%3c 48+12=60  <
%3e 48+14=62   >
%23 32+3=35    #  
#下面的好像没用到，也不确定
%2b  32+11=43  + 
%3b ;
%2c ,
```
后续见另一篇文章   
[border-theme](_posts/study/obsidian/border-theme.md)
{% post_link 'study/obsidian/border-theme' 'helo' %}