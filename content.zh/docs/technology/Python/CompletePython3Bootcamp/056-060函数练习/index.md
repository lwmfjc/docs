---
title: "056-060函数练习"
description: "056-060函数练习"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-18T12:52:05+08:00
lastmod: 2026-09-18T12:52:05+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# Python练习题

## 热身问题

```python
#两偶数则取最小，否则取最大
In [9]: def lesser_of_two_evens(a,b):
   ...:     if(a%2==0 and b%2==0):
   ...:         return min(a,b)
   ...:     else:
   ...:         return max(a,b)
   ...:

In [10]: lesser_of_two_evens(1,2)
Out[10]: 2

In [11]: lesser_of_two_evens(4,2)
Out[11]: 2
```

```python
#接收2单词的字符串，如果他们以同样字符开头则返回True，否则false
In [18]: def animal_crackers(str):
    ...:     words=str.lower().split()
    ...:     if(len(words)>=2 and words[0][0] == words[1][0]):
    ...:         return True
    ...:     else:
    ...:         return False
    ...:

In [19]: animal_crackers('Levelhelkd Ldkfjks')
Out[19]: True

In [20]: animal_crackers('Levelhelkd Kdkfjks')
Out[20]: False
```

```python
#存在20或者相加为20时返回True，否则False
In [26]: def makes_twenty(n1,n2):
    ...:     if(n1==20 or n2==20 or n1+n2 == 20):
    ...:         return True
    ...:     else:
    ...:         return False
    ...:

In [27]: makes_twenty(20,10)
Out[27]: True

In [28]: makes_twenty(12,8)
Out[28]: True

In [29]: makes_twenty(12,18)
Out[29]: False

In [30]: makes_twenty(20,18)
Out[30]: True

#或者
In [31]: def makes_twenty(n1,n2):
    ...:     return (n1==20 or n2==20 or n1+n2 == 20);
    ...:

In [32]: makes_twenty(12,18)
Out[32]: False

In [33]: makes_twenty(20,18)
Out[33]: True

In [34]: makes_twenty(12,8)
Out[34]: True
```

## 一级问题

```python
#把字符串首字符以及第4个字符大写，其他保持不变
In [53]: def old_macdonald(name):
    ...:     return name[0].upper()+name[1:3]+name[3].upper()
    ...:     +name[4:]
    ...:

In [54]: old_macdonald("macdonald")
Out[54]: 'MacD'
```

上面是错的，原因：

Python 的隐式续行只发生在：

- 括号 \(\)
- 方括号 \[\]
- 花括号 \{\}

```python
In [55]: def old_macdonald(name):
    ...:     return (name[0].upper()+name[1:3]+name[3].upper()
    ...:     +name[4:])
    ...:

In [56]: old_macdonald("macdonald")
Out[56]: 'MacDonald'
```

注意，capitalize()除了会把首字母大写，还会把余下的字符全部变为小写  

```python
In [58]: def old_macdonald(name):
    ...:     return name[:3].capitalize()+name[3:].capitalize()
    ...:

In [59]: old_macdonald("macdonald")
Out[59]: 'MacDonald'
```

```python
#把句子中的单词倒叙排列
In [69]: def master_yoda(text):
    ...:     texts=text.split()
    ...:     new_text='';
    ...:     for i in range(len(texts)-1,-1,-1):
    ...:         new_text+=texts[i]
    ...:         if(i != 0):
    ...:             new_text+=' '
    ...:     return new_text
    ...:

In [70]: master_yoda('I am home')
Out[70]: 'home am I'

In [71]: master_yoda('We are ready')
Out[71]: 'ready are We'

#或者使用join()
In [72]: def master_yoda(text):
    ...:     texts=text.split()
    ...:     texts=texts[::-1]
    ...:     return' '.join(texts)

In [73]: master_yoda('I am home')
Out[73]: 'home am I'

In [74]: master_yoda('We are ready')
Out[74]: 'ready are We'

#测试
In [75]: '123'.join(['a',])
Out[75]: 'a'

In [76]: '123'.join(['a','b'])
Out[76]: 'a123b'
```

```python
#如果给定数在100或200的10范围内则返回True
In [79]: def almost_there(n):
    ...:     return abs(100-n)<=10 or abs(200-n)<=10
    ...:

In [80]: almost_there(90)
Out[80]: True

In [81]: almost_there(104)
Out[81]: True

In [82]: almost_there(150)
Out[82]: False

In [83]: almost_there(209)
Out[83]: True
```

## 二级问题

```python
#如果列表中存在两个连续的3，则返回True，否则False

#方法1：每次检查1个数字
In [3]: def has_33(nums):
   ...:     has3=False
   ...:     n=0
   ...:     for num in nums:
   ...:         if(num==3):
   ...:             has3=True
   ...:             n+=1
   ...:         else:
   ...:             if(has3):
   ...:                 n-=1
   ...:             has3=False
   ...:         if(n==2 and has3==True):
   ...:             return True
   ...:     return False
   ...:

In [4]: has_33([1,3,3])
Out[4]: True

In [5]: has_33([1,3,2,3])
Out[5]: False

In [6]: has_33([1,3,3,3,3,2,3])
Out[6]: True

In [7]: has_33([1,3,1,3])
Out[7]: False

In [8]: has_33([3,1,3,1])
Out[8]: False

#方法2：每次检查2个数字
In [13]: def has_33_2(nums):
    ...:     #只需要访问到倒数第2个数即可
    ...:     for i in range(0,len(nums)-1):
    ...:         if nums[i] == 3 and nums[i+1] == 3:
    ...:             return True
    ...:     return False
    ...:

In [14]: has_33_2([3,1,3,1])
Out[14]: False

In [15]: has_33_2([3,1,3,3,1])
Out[15]: True

In [16]: has_33_2([1,3,3,1,3,1])
Out[16]: True

#方法3：简化方法2
In [18]: def has_33_3(nums):
    ...:     #只需要访问到倒数第2个数即可
    ...:     for i in range(0,len(nums)-1):
    ...:         if nums[i:i+2] == [3,3]:
    ...:             return True
    ...:     return False
    ...:

In [19]: has_33_3([1,3,3,1,3,1])
Out[19]: True

In [20]: has_33_3([1,3,1,3,1])
Out[20]: False

```

```python
#把字符串中每个字符重复3次
In [23]: def paper_doll(text):
    ...:     result=''
    ...:     for str in text:
    ...:         result+=(str*3)
    ...:     return result
    ...:

In [24]: paper_doll('hello')
Out[24]: 'hhheeellllllooo'

In [25]: paper_doll('Mississippi')
Out[25]: 'MMMiiissssssiiissssssiiippppppiii'
```

> 给定三个介于 1 到 11 之间的整数：
> 1. 未爆牌：若三数之和小于或等于 21，返回它们的和。
> 2. A牌调整：若三数之和超过 21 且 包含数值 11，则将总和减去 10。
> 3. 爆牌（BUST）：最后，若（调整后的）总和仍超过 21，返回 'BUST'。若没超过，则返回总和  

```python


In [37]: def blackjack(a,b,c):
    ...:     total=sum([a,b,c])
    ...:     if(total<=21):
    ...:         return total
    ...:     elif(11 in [a,b,c]):
    ...:         total-=10
    ...:     if(total>21):
    ...:         return 'BUST'
    ...:     else:
    ...:         return total
    ...:

In [38]: blackjack(5,6,7)
Out[38]: 18

In [39]: blackjack(9,9,9)
Out[39]: 'BUST'

In [40]: blackjack(9,9,11)
Out[40]: 19

#另一个方法
In [42]: def blackjack(a,b,c):
    ...:     total=sum([a,b,c])
    ...:     if(total<=21):
    ...:         return total
    ...:     elif(11 in [a,b,c] and total-10<=31):
    ...:         return total-10
    ...:     else:
    ...:         return 'BUST'
    ...:

In [43]: blackjack(9,9,11)
Out[43]: 19

In [44]: blackjack(9,9,9)
Out[44]: 'BUST'

In [45]: blackjack(5,6,7)
Out[45]: 18
```

> 
> 返回数组中所有数字的和，但需要忽略从数字 6 开始到下一个数字 9 为止（包含 6 和 9）的这段区间。每个出现的 6 后面都至少会跟一个 9。如果数组为空（或没有符合条件的数字），则返回 0。

```python

In [46]: def summer_69(arr):
    ...:     total=0
    ...:     add=True #默认相加
    ...:     for num in arr:
    ...:         while add:
					 #如果没有遇到6，就一直加，遇到6就停下来不加了
    ...:             if num!=6:
    ...:                 total+=num
    ...:                 break #break只跳出他所在的循环，不跳出外面的循环
    ...:             else:
    ...:                 add = False
    ...:         while not add:
    ...:             if num!=9:
    ...:                 break
    ...:             else:
					     #直到遇到9，接下来再继续上面add为True的逻辑相加
    ...:                 add=True
    ...:                 break
    ...:     return total
    
In [47]: summer_69([1,3,5])
Out[47]: 9

In [48]: summer_69([4,5,6,7,8,9])
Out[48]: 9

In [49]: summer_69([2,1,6,9,11])
Out[49]: 14
```

## 挑战题

~~这里我先跳过了，不涉及新的知识点~~  

