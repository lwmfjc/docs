---
title: "131-132爬虫_图书示例"
description: "131-132爬虫_图书示例"
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

> 每页20本书

```python
In [23]: base_url='https://books.toscrape.com/catalogue/page-{}.html'

In [24]: res=requests.get(base_url.format(1),headers=headers)

In [25]: soup=bs4.BeautifulSoup(res.text,'lxml')

In [26]: len(soup.select(".product_pod"))
Out[26]: 20
```

> 选择两颗星

> 转为字符串判断

```python
In [27]: products=soup.select(".product_pod")

In [28]: example=products[0]

In [30]: str(example)
Out[30]: '<article class="product_pod">\n<div class="image_container">\n<a href="a-light-in-the-attic_1000/index.html"><img alt="A Light in the Attic" class="thumbnail" src="../media/cache/2c/da/2cdad67c44b002e7ead0cc35693c0e8b.jpg"/></a>\n</div>\n<p class="star-rating Three">\n<i class="icon-star"></i>\n<i class="icon-star"></i>\n<i class="icon-star"></i>\n<i class="icon-star"></i>\n<i class="icon-star"></i>\n</p>\n<h3><a href="a-light-in-the-attic_1000/index.html" title="A Light in the Attic">A Light in the ...</a></h3>\n<div class="product_price">\n<p class="price_color">Â£51.77</p>\n<p class="instock availability">\n<i class="icon-ok"></i>\n    \n        In stock\n    \n</p>\n<form>\n<button class="btn btn-primary btn-block" data-loading-text="Adding..." type="submit">Add to basket</button>\n</form>\n</div>\n</article>'


In [31]: 'star-rating Three' in str(example)
Out[31]: True

In [32]: 'star-rating Two' in str(example)
Out[32]: False
```

> 或者判断是否返回空列表

```python
In [33]: example.select(".star-rating.Three")
Out[33]:
[<p class="star-rating Three">
 <i class="icon-star"></i>
 <i class="icon-star"></i>
 <i class="icon-star"></i>
 <i class="icon-star"></i>
 <i class="icon-star"></i>
 </p>]

In [34]: example.select(".star-rating.Two")
Out[34]: []

In [35]: type(example.select(".star-rating.Three")[0])
Out[35]: bs4.element.Tag

In [38]: type(example)
Out[38]: bs4.element.Tag

In [40]: type(soup)
Out[40]: bs4.BeautifulSoup

#bs4.BeautifulSoup继承bs4.element.Tag类
In [41]: issubclass(bs4.BeautifulSoup, bs4.element.Tag)
Out[41]: True

```

select() 返回 Tag，而不是 BeautifulSoup？

因为 .product_pod 匹配的是 HTML 标签：

比如：

```
<article class="product_pod">
    <h3>
        <a>Book</a>
    </h3>
</article>
```

这个东西在 BeautifulSoup 里表示：

```
Tag(
    name="article",
    attrs={"class": ["product_pod"]}
)
```

它不是一个完整 HTML 文档，所以类型是 Tag。

> 获取标题

```python
In [43]: example
Out[43]:
<article class="product_pod">
<div class="image_container">
<a href="a-light-in-the-attic_1000/index.html"><img alt="A Light in the Attic" class="thumbnail" src="../media/cache/2c/da/2cdad67c44b002e7ead0cc35693c0e8b.jpg"/></a>
</div>
<p class="star-rating Three">
<i class="icon-star"></i>
<i class="icon-star"></i>
<i class="icon-star"></i>
<i class="icon-star"></i>
<i class="icon-star"></i>
</p>
<h3><a href="a-light-in-the-attic_1000/index.html" title="A Light in the Attic">A Light in the ...</a></h3>
<div class="product_price">
<p class="price_color">Â£51.77</p>
<p class="instock availability">
<i class="icon-ok"></i>

        In stock

</p>
<form>
<button class="btn btn-primary btn-block" data-loading-text="Adding..." type="submit">Add to basket</button>
</form>
</div>
</article>

In [44]: example.select('a')
Out[44]:
[<a href="a-light-in-the-attic_1000/index.html"><img alt="A Light in the Attic" class="thumbnail" src="../media/cache/2c/da/2cdad67c44b002e7ead0cc35693c0e8b.jpg"/></a>,
 <a href="a-light-in-the-attic_1000/index.html" title="A Light in the Attic">A Light in the ...</a>]

In [45]: example.select('a')[1]['title']
Out[45]: 'A Light in the Attic'

#bs4.element.Tag，所以可以用字典形式获取'title'
In [46]: type(example.select('a')[1])
Out[46]: bs4.element.Tag
```

***总结：可以通过字符串检查，或者通过example ~~bs4.element.Tag类~~ 的select某个评级类判断某本书是不是两级，是的话再 select('a')\[1\]再来获取title*** 

```python
In [6]: base_url=f'https://books.toscrape.com/catalogue/page-{page_num}.html'


In [51]: two_star_titles=[]
    ...: headers= {'User-Agent': 'my-learning-script/1.0 hello@163.com'}
    ...: for n in range(1,51):
    ...:     scrape_url=base_url.format(n)
    ...:     res=requests.get(scrape_url,headers=headers)
    ...:     soup=bs4.BeautifulSoup(res.text,'lxml')
    ...:     books=soup.select(".product_pod")
    ...:     #会等很久，我加了每一页的提示
    ...:     print(f'Page.{n} book getting ---')
    ...:     for book in books:
    ...: #        if 'star-rating Two' in str(book)
    ...:         if len(book.select('.star-rating.Two')) !=0:
    ...:             book_title=book.select('a')[1]['title']
    ...:             two_star_titles.append(book_title)
    ...:
Page.1 book getting ---
Page.2 book getting ---
....
Page.51 book getting ---

#得到所有两星书籍的列表
In [53]: len(two_star_titles)
Out[53]: 196

In [54]: two_star_titles
Out[54]:
['Starving Hearts (Triangular Trade Trilogy, #1)',
 'Libertarianism for Beginners',
 "It's Only the Himalayas",
 'How Music Works',
 'Maude (1883-1993):She Grew Up wit
 ...
 
 ]
```