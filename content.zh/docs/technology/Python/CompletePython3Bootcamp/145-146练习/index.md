---
title: "145-146练习"
description: "145-146练习"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-28T17:19:50+08:00
lastmod: 2026-09-28T17:19:50+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
> 读取csv文件内容的对角线部分

```python
In [3]: data=open('Exercise_Files/find_the_link.csv',encoding='utf-8')

In [5]: import csv

In [6]: csv_data=csv.reader(data)

In [7]: data_lines=list(csv_data)

In [14]: data_lines
Out[14]:
[['h',
  '53',
  '24',
  '46',
  '4',
  '11',
  '3',
  '35',
  '17',
  '52',
  '9',
  '60',
  '26',
  '60',
  '72',
  '39',
  '11',
  '80',
  '86',
  '66',
  '59',
  '9',
  '41',
  '33',
  '11',
  '42',
  '69',
  '74',
  '91',
  '61',
  '5',
  '69',
  '17',
  '17',
  '78',
  '6',
  '51',
  '54',
  '54',
  '94',
  '47',
  '37',
  '0',
  '16',
  '71',
  '6',
  '83',
  '7',
  '6',
  '38',
  '61',
  '18',
  '68',
  '15',
  '2',
  '81',
  '49',
  '5',
  '17',
  '21',
  '36',
  '63',
  '38',
  '24',
  '3',
  '99'],
 ['85',
  't',
  '31',
  '54',
  '60',
  '22',
  '77',
  '39',
  '93',
  '38',
  '31',
  '16',
  '29',
  '27',
  '8',
  '35',
  '0',
  '54',
  '84',
  '21',
  '47',
  '37',
  '66',
  '83',
  '26',
  '22',
  '68',
  '25',
  '44',
  '81',
  '27',
  '68',
  '17',
  '63',
  '13',
  '99',
  '38',
  '43',
  '87',
  '83',
  '73',
  '88',
  '67',
  '5',
  '12',
  '10',
  '7',
  '58',
  '64',
  '56',
  '53',
  '88',
  '96',
  '20',
  '7',
  '85',
  '94',
  '23',
  '14',
  '79',
  '24',
  '27',
  '90',
  '40',
  '27',
  '8'],
 ['22',
  '98',
  't',
  '83',
  '33',
  '53',
  '66',
  '13',
  '81',
  '53',
  '60',
  '52',
  '45',
  '51',
  '39',
  '98',
  '14',
  '94',
  '68',
  '5',
  '99',
  '62',
  '68',
  '95',
  '50',
  '81',
  '64',
  '58',
  '96',
  '1',
  '71',
  '4',
  '60',
  '57',
  '84',
  '39',
  '5',
  '24',
  '79',
  '19',
  '86',
  '20',
  '15',
  '55',
  '68',
  '26',
  '81',
  '78',
  '3',
  '2',
  '24',
  '64',
  '17',
  '86',
  '3',
  '16',
  '89',
  '81',
  '33',
  '70',
  '42',
  '5',
  '31',
  '42',
  '45',
  '42'],
  # 省略...

In [8]: data_lines[0][0]
Out[8]: 'h' 

```

> 解法1

```python
In [12]: str=''
    ...: line_num=0
    ...: while True:
    ...:     if(line_num >= len(data_lines)):
    ...:         break
    ...:     str+=(data_lines[line_num][line_num])
    ...:     line_num+=1
    ...:

In [13]: print(str)
https://drive.google.com/open?id=1G6SEgg018UB4_4xsAJJ5TdzrhmXipr4Q
```

> 解法2

```python

In [16]: link_str=''

#enumerate 可以同时得到列表的下标，以及对应下标对应的内容
In [17]: for row_num,data in enumerate(data_lines):
    ...:     link_str += data[row_num]
    ...:

In [18]: print(link_str)
https://drive.google.com/open?id=1G6SEgg018UB4_4xsAJJ5TdzrhmXipr4Q
```

> 从pdf文件中找到电话号码

> 先找到文件中所有文本

```python
In [20]: import PyPDF2

In [21]: f=open('Exercise_Files/Find_the_Phone_Number.pdf','rb')

In [22]: pdf_reader=PyPDF2.PdfReader(f)

In [23]: pdf_reader.pages
Out[23]: <PyPDF2._page._VirtualList at 0x7b5d78ed2c30>

In [24]: len(pdf_reader.pages)
Out[24]: 17

In [25]: import re

In [26]: pattern=r'\d{3}'

In [27]: all_text=''

In [28]: for page in pdf_reader.pages:
    ...:     page_text = page.extract_text()
    ...:     all_text=all_text+ ' ' + page_text
    ...:

```

> 查找

```python
In [30]: re.findall(pattern,all_text)
Out[30]: ['000', '000', '000', '505', '503', '445']

#查找3个连续的数字（以迭代器为结果）
In [31]: for match in re.finditer(pattern,all_text):
    ...:     print(match)
    ...:
<re.Match object; span=(650, 653), match='000'>
<re.Match object; span=(18270, 18273), match='000'>
<re.Match object; span=(35890, 35893), match='000'>
<re.Match object; span=(42919, 42922), match='505'>
<re.Match object; span=(42923, 42926), match='503'>
<re.Match object; span=(42927, 42930), match='445'>


In [32]: all_text[42919:42919+20]
Out[32]: '505.503.4455. So hor'

In [33]: all_text[42909:42919+20]
Out[33]: 'number is 505.503.4455. So hor'

#注意，这里的点仅表示单个字符，并不特殊点，因为没有转义
In [34]: pattern=r'\d{3}.\d{3}.\d{4}'

In [35]: for match in re.finditer(pattern,all_text):
    ...:     print(match)
    ...:
<re.Match object; span=(42919, 42931), match='505.503.4455'>
```