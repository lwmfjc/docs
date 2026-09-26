---
title: "051-052使用函数、元组解包"
description: "051-052使用函数、元组解包"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-17T22:18:56+08:00
lastmod: 2026-09-17T22:18:56+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# Python的循环控制关键字

Python ***循环控制关键字***主要有这几个：

| 关键字        | 作用                        | 使用位置                 |
| ---------- | ------------------------- | -------------------- |
| `break`    | 立即结束当前循环                  | `for` / `while` 循环内部 |
| `continue` | 跳过本次循环剩余代码，进入下一次循环        | `for` / `while` 循环内部 |
| `else`     | 循环正常结束后执行（没有被 `break` 打断） | `for` / `while` 后面   |
| `pass`     | 什么也不做，占位                  | 任何需要语句的位置            |
|            |                           |                      |

## 1. break

例如找数字：

```python
for i in range(10):
    if i == 5:
        break
    print(i)
```

输出：

```
0
1
2
3
4
```

当 `i == 5` 时：

```
break
```

直接跳出整个 `for` 循环。

类似 C/C++：

```cpp
for(int i=0;i<10;i++)
{
    if(i==5)
        break;
}
```

## 2. continue

例如跳过偶数：

```python
for i in range(10):
    if i % 2 == 0:
        continue

    print(i)
```

输出：

```
1
3
5
7
9
```

执行流程：

```
i=0
 ↓
满足偶数
 ↓
continue
 ↓
跳到下一轮

i=1
 ↓
打印
```

对应 C/C++：

```cpp
if(i%2==0)
    continue;
```

## 3. Python 特有：循环 else

这个很多 C/C++ 程序员第一次看到会觉得奇怪。

例如：

```python
for i in range(5):
    print(i)
else:
    print("循环结束")
```

输出：

```
0
1
2
3
4
循环结束
```

因为循环**正常结束**，所以执行 `else`。

但是：

```python
for i in range(5):
    if i == 3:
        break
else:
    print("循环结束")
```

输出：

```
0
1
2
```

不会打印：

```
循环结束
```

因为被 `break` 中断了。

常用于搜索：

```python
nums = [3, 5, 7, 9]

for n in nums:
    if n == 7:
        print("找到了")
        break
else:
    print("没找到")
```

## 4. pass

相当于：

> 这里语法上需要写东西，但我暂时什么都不做。

例如：

```python
def test():
    pass
```

否则：

```python
def test():

```

会报错。

也可以：

```python
for i in range(10):
    if i == 5:
        pass
    print(i)
```

`pass` 不会影响流程。

## Python 还有几个和流程相关的关键字

### return

函数返回，并结束函数：

```python
def test():
    print("开始")
    return
    print("结束")

test()
```

输出：

```
开始
```

后面的代码不会执行。

---

### yield

生成器相关：

```python
def nums():
    yield 1
    yield 2
    yield 3
```

它不是普通返回，而是暂停函数，下次继续。

### raise

主动抛异常：

```python
raise Exception("错误")
```

类似 C++：

```cpp
throw exception();
```

### 总结（和 C/C++ 对比）

| Python     | C/C++      | 作用        |
| ---------- | ---------- | --------- |
| `break`    | `break`    | 跳出循环      |
| `continue` | `continue` | 跳过本轮      |
| `return`   | `return`   | 结束函数      |
| `pass`     | 无直接对应      | 空语句       |
| `raise`    | `throw`    | 抛异常       |
| `yield`    | 无直接对应      | 生成器暂停     |
| 循环 `else`  | 无          | 循环正常结束后执行 |

如果你从 C/C++ 转 Python，前几个（`break`、`continue`、`return`）几乎一样，主要需要适应的是 Python 的 `else` 和 `yield`。

# 使用Python实现函数逻辑
## 判断奇偶

```python
>>> def even_check(number):
...     #result=number%2==0
...     return number%2==0
...
>>> even_check(12)
True
>>> even_check(11)
False
```

```python
#列表存在任意偶数时返回真
In [2]: def check_even_list(num_list):
   ...:
   ...:     for number in num_list:
   ...:         if number%2 == 0:
   ...:             return True
   ...:         else:
   ...:             pass #目前这里也可以用continue替代
   ...:

In [3]: check_even_list([1,3,5])

In [4]: check_even_list([1,3,5,4])
Out[4]: True

In [5]: def check_even_list(num_list):
   ...:
   ...:     for number in num_list:
   ...:         if number%2 == 0:
   ...:             return True
   ...:         else:
   ...:             continue
   ...:

In [6]: check_even_list([1,3,5,4])
Out[6]: True

In [7]: check_even_list([1,3,5])

In [8]: check_even_list([1,3,4,5])
Out[8]: True
```

```python
#没有任何偶数时返回假

#下面这个函数定义不符合预期
In [50]: def check_even_list(num_list):
    ...:
    ...:     for number in num_list:
    ...:         if number%2 == 0:
    ...:             return True
    ...:         else:
    ...:             return False
    ...:

In [51]: check_even_list([1,3,4,5])
Out[51]: False

```

**正确，符合预期：**  

```python
#Python 没有 {}，嵌套层级完全靠缩进表示。对于 Python 来说，缩进不是代码格式，而是语法的一部分。
In [52]: def check_even_list(num_list):
    ...:
    ...:     for number in num_list:
    ...:         if number%2 == 0:
    ...:             return True
    ...:         else:
    ...:             pass
    ...:     return False

In [53]: check_even_list([1,3,4,5])
Out[53]: True

In [54]: check_even_list([1,3,3,55,5])
Out[54]: False
```

### 注意这里的返回类型

**Python 函数没有固定返回类型，但每次调用一定产生一个返回结果；如果没有显式 return，或者 return 后没有值，返回结果就是 None。**

```python
In [9]: type(check_even_list([1,3,5]))
Out[9]: NoneType

In [10]: None==check_even_list([1,3,5])
Out[10]: True

In [11]: def testa3():
    ...:     print('hi')
    ...:

In [12]: testa3()
hi

In [13]: type(testa3())
hi
Out[13]: NoneType
```

yield 中，`g=nums;mynum=next(g)`中mynum也是有返回类型的

```python
In [49]: g=nums();type(next(g))
Out[49]: NoneType
```

```python
In [39]: def nums():
    ...:     yield None
    ...:     yield 20
    ...:

In [40]: g=nums()

In [41]: type(next(g))
Out[41]: NoneType

In [42]: type(next(g))
Out[42]: int

In [43]: type(next(g))
---------------------------------------------------------------------------
StopIteration                             Traceback (most recent call last)
Cell In[43], line 1
----> 1 type(next(g))

StopIteration:

In [44]: g=nums()

In [45]: type(next(g))
Out[45]: NoneType
```

## 返回所有偶数

```python
In [55]: def check_even_list(num_list):
    ...:     #return all even numbers in a list
    ...:
    ...:     #placeholder variables
    ...:     even_nums=[]
    ...:
    ...:     for number in num_list:
    ...:         if number%2 == 0:
    ...:             even_nums.append(number)
    ...:             #return True
    ...:         else:
    ...:             pass
    ...:     return even_nums
    ...:

In [56]: check_even_list([1,3,3,55,5])
Out[56]: []

In [57]: check_even_list([1,3,3,55,2,4,2,1,4,5])
Out[57]: [2, 4, 2, 4]
```

```python
#有偶数则返回所有偶数，没有的话返回False
In [60]: def check_even_list(num_list):
    ...:     #return all even numbers in a list
    ...:
    ...:     #placeholder variables
    ...:     even_nums=[]
    ...:
    ...:     for number in num_list:
    ...:         if number%2 == 0:
    ...:             even_nums.append(number)
    ...:             #return True
    ...:         else:
    ...:             pass
    ...:
    ...:     if(len(even_nums)==0):
    ...:         return False
    ...:     else:
    ...:         return even_nums
In [61]: check_even_list([1,3,2,3])
Out[61]: [2]

In [62]: check_even_list([1,4,3,2,3])
Out[62]: [4, 2]

In [63]: check_even_list([1,3,3])
Out[63]: False
```

# 使用函数进行元组解包

## 元组解包回顾

```python
In [2]: stock_prices=[('appl',200),('goog',400),('msft',100)]

In [3]: for item in stock_prices:
   ...:     print(item)
   ...:
('appl', 200)
('goog', 400)
('msft', 100)

In [4]: for ticker,price in stock_prices:
   ...:     print(ticker)
   ...:
appl
goog
msft
```

## 例子

```python
In [6]: work_hours=[('Abby',100),('Billy',400),('Cassie',800)] 

In [12]: def employee_check(work_hours):
    ...:     current_max=0
    ...:     employee_of_month=''
    ...:     for employee,hours in work_hours:
    ...:         if hours>current_max:
    ...:             current_max=hours
    ...:             employee_of_month=employee
    ...:     #Return
    ...:     return (employee_of_month,current_max)
    ...:

In [13]: employee_check(work_hours)
Out[13]: ('Cassie', 800)

In [14]: work_hours=[('Abby',100),('Billy',4000),('Cassie',800)]

In [15]: employee_check(work_hours)
Out[15]: ('Billy', 4000)
```

如果解包属性数量超过元组时会报错  

```python
In [16]: name,hours = employee_check(work_hours)

In [17]: name
Out[17]: 'Billy'

In [18]: hours
Out[18]: 4000

In [19]: name,hours,location = employee_check(work_hours)
---------------------------------------------------------------------------
ValueError                                Traceback (most recent call last)
Cell In[19], line 1
----> 1 name,hours,location = employee_check(work_hours)

ValueError: not enough values to unpack (expected 3, got 2)

#可以先查看一下元组数量再说
In [23]: len(employee_check(work_hours))
Out[23]: 2
```



