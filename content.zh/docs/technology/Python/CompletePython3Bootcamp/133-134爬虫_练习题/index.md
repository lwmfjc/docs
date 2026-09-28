---
title: "133-134爬虫_练习题"
description: "133-134爬虫_练习题"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-27T22:32:24+08:00
lastmod: 2026-09-27T22:32:24+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 需要导入的库

```python
In [2]: import bs4

In [3]: import requests
```

# 获取作者

```Python
In [6]: base_url='https://quotes.toscrape.com/'

In [7]: res=requests.get(base_url) 

In [8]: res.text
Out[8]: '<!DOCTYPE html>\n<html lang="en">\n<head>\n\t<meta charset="UTF-8">\n\t<title>Quotes to Scrape</title>\n    <link rel="stylesheet" href="/static/bootstrap.min.css">\n    <link rel="stylesheet" href="/static/main.css">\n    \n    \n</head>\n<body>\n    <div class="container">\n        <div class="row header-box">\n            <div class="col-md-8">\n     ..... 省略     <a class="tag" style="font-size: 6px" href="/tag/simile/">simile</a>\n            </span>\n            \n        \n    </div>\n</div>\n\n    </div>\n    <footer class="footer">\n        <div class="container">\n            <p class="text-muted">\n                Quotes by: <a href="https://www.goodreads.com/quotes">GoodReads.com</a>\n            </p>\n            <p class="copyright">\n                Made with <span class=\'zyte\'>❤</span> by <a class=\'zyte\' href="https://www.zyte.com">Zyte</a>\n            </p>\n        </div>\n    </footer>\n</body>\n</html>'

In [9]: soup=bs4.BeautifulSoup(res.text,'lxml')

In [15]: rs_authors=soup.select('.author')

In [20]: authors=set()
    ...: for author in rs_authors:
    ...:     authors.add(author.getText())
    ...:

In [21]: authors
Out[21]:
{'Albert Einstein',
 'André Gide',
 'Eleanor Roosevelt',
 'J.K. Rowling',
 'Jane Austen',
 'Marilyn Monroe',
 'Steve Martin',
 'Thomas A. Edison'}
 
 
```

# 第一页所有名言

```python
In [26]: quotes=[]
    ...: rs_quotes=soup.select('.text')
    ...: for quote in rs_quotes:
    ...:     quotes.append(quote.getText())
    ...:
    ...:

In [27]: quotes
Out[27]:
['“The world as we have created it is a process of our thinking. It cannot be changed without changing our thinking.”',
 '“It is our choices, Harry, that show what we truly are, far more than our abilities.”',
 '“There are only two ways to live your life. One is as though nothing is a miracle. The other is as though everything is a miracle.”',
 '“The person, be it gentleman or lady, who has not pleasure in a good novel, must be intolerably stupid.”',
 "“Imperfection is beauty, madness is genius and it's better to be absolutely ridiculous than absolutely boring.”",
 '“Try not to become a man of success. Rather become a man of value.”',
 '“It is better to be hated for what you are than to be loved for what you are not.”',
 "“I have not failed. I've just found 10,000 ways that won't work.”",
 "“A woman is like a tea bag; you never know how strong it is until it's in hot water.”",
 '“A day without sunshine is like, you know, night.”']
```

# 所有tag

```python
In [39]: lytags=[]
    ...: rs_tags=soup.select('.tag-item')
    ...: for tag in rs_tags:
    ...:     print(tag.getText())
    ...:

love


inspirational


life


humor


books


reading


friendship


friends


truth


simile
```

# 获取所有页面的作者

> 在网络爬虫中，代码越健壮越好，尤其是网站经常会变动
## 提前知道页面总数

```python
In [49]: url='https://quotes.toscrape.com/page/'

In [49]: authors=set()
    ...: for page in range(1,11):
    ...:     page_url=url+str(page)
    ...:     print(f'getting page {page} .....')
    ...:     res=requests.get(page_url)
    ...:     soup=bs4.BeautifulSoup(res.text,'lxml')
    ...:     for name in soup.select(".author"):
    ...:         authors.add(name.text)
    ...:
getting page 1 .....
getting page 2 .....
getting page 3 .....
getting page 4 .....
getting page 5 .....
getting page 6 .....
getting page 7 .....
getting page 8 .....
getting page 9 .....
getting page 10 .....

In [51]: len(authors)
Out[51]: 50
```

## 不知道页面总数

```python

In [53]: page_url=url+str(9999999999)

In [54]: res=requests.get(page_url)
|D-chain|-<>-127.0.0.1:12983-<><>-35.211.122.109:443-<><>-OK


In [66]: "No quotes found!" in res.text
Out[66]: True

In [67]: soup=bs4.BeautifulSoup(res.text,'lxml')
```

> 结合

```python
In [69]: page_still_valid=True
    ...: authors=set()
    ...: page=1
    ...: while page_still_valid:
    ...:     page_url=url+str(page)
    ...:     res=requests.get(page_url)
    ...:     if "No quotes found!" in res.text:
    ...:         break
    ...:     soup=bs4.BeautifulSoup(res.text,'lxml')
    ...:     for name in soup.select(".author"):
    ...:         authors.add(name.text)
    ...:     page=page+1
    ...:

In [70]: authors
Out[70]:
{'Albert Einstein',
 'Alexandre Dumas fils',
 'Alfred Tennyson',
 'Allen Saunders',
 'André Gide',
 'Ayn Rand',
 'Bob Marley',
 'C.S. Lewis',
 'Charles Bukowski',
 'Charles M. Schulz',
 'Douglas Adams',
 'Dr. Seuss',
 'E.E. Cummings',
 'Eleanor Roosevelt',
 'Elie Wiesel',
 'Ernest Hemingway',
 'Friedrich Nietzsche',
 'Garrison Keillor',
 'George Bernard Shaw',
 'George Carlin',
 'George Eliot',
 'George R.R. Martin',
 'Harper Lee',
 'Haruki Murakami',
 'Helen Keller',
 'J.D. Salinger',
 'J.K. Rowling',
 'J.M. Barrie',
 'J.R.R. Tolkien',
 'James Baldwin',
 'Jane Austen',
 'Jim Henson',
 'Jimi Hendrix',
 'John Lennon',
 'Jorge Luis Borges',
 'Khaled Hosseini',
 "Madeleine L'Engle",
 'Marilyn Monroe',
 'Mark Twain',
 'Martin Luther King Jr.',
 'Mother Teresa',
 'Pablo Neruda',
 'Ralph Waldo Emerson',
 'Stephenie Meyer',
 'Steve Martin',
 'Suzanne Collins',
 'Terry Pratchett',
 'Thomas A. Edison',
 'W.C. Fields',
 'William Nicholson'}
```