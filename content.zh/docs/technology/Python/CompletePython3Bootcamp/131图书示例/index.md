---
title: "131图书示例"
description: "131图书示例"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-27T19:34:56+08:00
lastmod: 2026-09-27T19:34:56+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
> 专门用于练习爬虫的网站： https://toscrape.com/

> 本章练习 https://books.toscrape.com/ 

- 试着获取所有两星评分的书籍
- 从第二页跳到下一页
  https://books.toscrape.com/catalogue/page-1.html
  https://books.toscrape.com/catalogue/page-2.html  
  https://books.toscrape.com/catalogue/page-3.html

```python
In [5]: page_num=20

In [6]: base_url=f'https://books.toscrape.com/catalogue/page-{page_num}.html'

In [7]: base_url
Out[7]: 'https://books.toscrape.com/catalogue/page-20.html'
```

