---
title: "144PDF"
description: "144PDF"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-28T16:50:30+08:00
lastmod: 2026-09-28T16:50:30+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
- 仅仅扫描得到的PDF，Python极有可能无法读取他
- 这里使用PyPDF2，且仅使用本课程可以读取的pdf文件进行教学测试
- `pip install PyPDF2`

> 如果处理自己的pdf时出现问题，那么需要使用其他的库

> 且本讲只专注从pdf中读取信息

> 简单读取

```python
In [2]: import PyPDF2

In [3]: f = open("Working_Business_Proposal.pdf",'rb')

##方法过期
In [4]: pdf_reader=PyPDF2.PdfFileReader(f)
---------------------------------------------------------------------------
DeprecationError                          Traceback (most recent call last)
Cell In[4], line 1
----> 1 pdf_reader=PyPDF2.PdfFileReader(f)

File ~/.venv/lib/python3.12/site-packages/PyPDF2/_reader.py:1974, in PdfFileReader.__init__(self, *args, **kwargs)
   1973 def __init__(self, *args: Any, **kwargs: Any) -> None:
-> 1974     deprecation_with_replacement("PdfFileReader", "PdfReader", "3.0.0")
   1975     if "strict" not in kwargs and len(args) < 2:
   1976         kwargs["strict"] = True  # maintain the default

File ~/.venv/lib/python3.12/site-packages/PyPDF2/_utils.py:369, in deprecation_with_replacement(old_name, new_name, removed_in)
    363 def deprecation_with_replacement(
    364     old_name: str, new_name: str, removed_in: str = "3.0.0"
    365 ) -> None:
    366     """
    367     Raise an exception that a feature was already removed, but has a replacement.
    368     """
--> 369     deprecation(DEPR_MSG_HAPPENED.format(old_name, removed_in, new_name))

File ~/.venv/lib/python3.12/site-packages/PyPDF2/_utils.py:351, in deprecation(msg)
    350 def deprecation(msg: str) -> None:
--> 351     raise DeprecationError(msg)

DeprecationError: PdfFileReader is deprecated and was removed in PyPDF2 3.0.0. Use PdfReader instead.

In [5]: pdf_reader=PyPDF2.PdfReader(f)

#方法过期
In [6]: pdf_reader.numPages
---------------------------------------------------------------------------
DeprecationError                          Traceback (most recent call last)
Cell In[6], line 1
----> 1 pdf_reader.numPages

File ~/.venv/lib/python3.12/site-packages/PyPDF2/_reader.py:467, in PdfReader.numPages(self)
    460 @property
    461 def numPages(self) -> int:  # pragma: no cover
    462     """
    463     .. deprecated:: 1.28.0
    464
    465         Use :code:`len(reader.pages)` instead.
    466     """
--> 467     deprecation_with_replacement("reader.numPages", "len(reader.pages)", "3.0.0")
    468     return self._get_num_pages()

File ~/.venv/lib/python3.12/site-packages/PyPDF2/_utils.py:369, in deprecation_with_replacement(old_name, new_name, removed_in)
    363 def deprecation_with_replacement(
    364     old_name: str, new_name: str, removed_in: str = "3.0.0"
    365 ) -> None:
    366     """
    367     Raise an exception that a feature was already removed, but has a replacement.
    368     """
--> 369     deprecation(DEPR_MSG_HAPPENED.format(old_name, removed_in, new_name))

File ~/.venv/lib/python3.12/site-packages/PyPDF2/_utils.py:351, in deprecation(msg)
    350 def deprecation(msg: str) -> None:
--> 351     raise DeprecationError(msg)

DeprecationError: reader.numPages is deprecated and was removed in PyPDF2 3.0.0. Use len(reader.pages) instead.

In [7]: len(pdf_reader.pages)
Out[7]: 5

In [8]: page_one=pdf_reader.pages[0]

In [9]: page_one_text=page_one.extract_text()

In [10]: page_one_text
Out[10]: 'Business Proposal The Revolution is Coming Leverage agile frameworks to provide a robust synopsis for high level overviews. Iterative approaches to corporate strategy foster collaborative thinking to further the overall value proposition. Organically grow the holistic world view of disruptive innovation via workplace diversity and empowerment. Bring to the table win-win survival strategies to ensure proactive domination. At the end of the day, going forward, a new normal that has evolved from generation X is on the runway heading towards a streamlined cloud solution. User generated content in real-time will have multiple touchpoints for offshoring. Capitalize on low hanging fruit to identify a ballpark value added activity to beta test. Override the digital divide with additional clickthroughs from DevOps. Nanotechnology immersion along the information highway will close the loop on focusing solely on the bottom line. Podcasting operational change management inside of workﬂows to establish a framework. Taking seamless key performance indicators ofﬂine to maximise the long tail. Keeping your eye on the ball while performing a deep dive on the start-up mentality to derive convergence on cross-platform integration. Collaboratively administrate empowered markets via plug-and-play networks. Dynamically procrastinate B2C users after installed base beneﬁts. Dramatically visualize customer directed convergence without revolutionary ROI. Efﬁciently unleash cross-media information without cross-media value. Quickly maximize timely deliverables for real-time schemas. Dramatically maintain clicks-and-mortar solutions without functional solutions. BUSINESS PROPOSAL!1'

In [11]: f.close()
```

> 写入

> 只能通过重新新增一个pdf文件，并添加一页来写入文本

```python
In [13]: f=open('Working_Business_Proposal.pdf','rb')

In [14]: pdf_reader=PyPDF2.PdfReader(f)

In [16]: first_page=pdf_reader.pages[0]

In [18]: pdf_writer=PyPDF2.PdfWriter()

In [19]: type(first_page)
Out[19]: PyPDF2._page.PageObject 

In [21]: pdf_writer.add_page(first_page)
Out[21]:
{'/Type': '/Page',
 '/Resources': {'/ProcSet': ['/PDF', '/Text'],
  #....省略了一堆
   '/TT3': {'/Type': '/Font',
    '/Subtype': '/TrueType',
    '/BaseFont': '/VJMLYK+Baskerville',
    '/FontDescriptor': {'/Type': '/FontDescriptor',
     '/FontName': '/VJMLYK+Baskerville',
     '/Flags': 4,
     '/FontBBox': [-506, -344, 1765, 961],
     '/ItalicAngle': 0,
     '/Ascent': 898,
     '/Descent': -246,
     '/CapHeight': 669,
     '/StemV': 96,
     '/XHeight': 400,
     '/StemH': 22,
     '/AvgWidth': 579,
     '/MaxWidth': 1791,
     '/FontFile2': {'/Length1': 508, '/Filter': '/FlateDecode'}},
    '/ToUnicode': {'/Filter': '/FlateDecode'},
    '/FirstChar': 33,
    '/LastChar': 33,
    '/Widths': [0]}}},
 '/Contents': {'/Filter': '/FlateDecode'},
 '/MediaBox': [0, 0, 612, 792],
 '/Parent': {'/Type': '/Pages',
  '/Count': 1,
  '/Kids': [IndirectObject(4, 0, 130910706566928)]}}


In [22]: pdf_output=open('ly_Some_BrandNew_Doc.pdf','wb')

In [23]: pdf_writer.write(pdf_output)
Out[23]: (False, <_io.BufferedWriter name='ly_Some_BrandNew_Doc.pdf'>)

In [24]: f.close()

In [25]: pdf_output.close()
#在windows上打开该文件ly_Some_BrandNew_Doc.pdf，正常读取
```

> 获取pdf中所有页面的文本

```python
In [35]: f=open('Working_Business_Proposal.pdf','rb')

In [36]: pdf_text=[]

In [37]: pdf_reader=PyPDF2.PdfReader(f)

In [40]: for page in pdf_reader.pages:
    ...:     pdf_text.append(page.extract_text())
    ...:

#打印第一页
In [42]: print(pdf_text[0])
Business Proposal The Revolution is Coming Leverage agile frameworks to provide a robust synopsis for high level overviews. Iterative approaches to corporate strategy foster collaborative thinking to further the overall value proposition. Organically grow the holistic world view of disruptive innovation via workplace diversity and empowerment. Bring to the table win-win survival strategies to ensure proactive domination. At the end of the day, going forward, a new normal that has evolved from generation X is on the runway heading towards a streamlined cloud solution. User generated content in real-time will have multiple touchpoints for offshoring. Capitalize on low hanging fruit to identify a ballpark value added activity to beta test. Override the digital divide with additional clickthroughs from DevOps. Nanotechnology immersion along the information highway will close the loop on focusing solely on the bottom line. Podcasting operational change management inside of workﬂows to establish a framework. Taking seamless key performance indicators ofﬂine to maximise the long tail. Keeping your eye on the ball while performing a deep dive on the start-up mentality to derive convergence on cross-platform integration. Collaboratively administrate empowered markets via plug-and-play networks. Dynamically procrastinate B2C users after installed base beneﬁts. Dramatically visualize customer directed convergence without revolutionary ROI. Efﬁciently unleash cross-media information without cross-media value. Quickly maximize timely deliverables for real-time schemas. Dramatically maintain clicks-and-mortar solutions without functional solutions. BUSINESS PROPOSAL!1
```