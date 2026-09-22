---
title: "093-"
description: "093-"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-22T17:19:17+08:00
lastmod: 2026-09-22T17:19:17+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 里程碑（练习面向对象编程）

> 本章我使用了vscode进行编写单独的.py文件并直接运行（为了避免拷贝文本、大段代码出问题难以查找之类的问题），需要安装python插件。不过我的.py文件是放在ubuntu24.04中，通过vscode远程连接上并运行的，不在本地win11中

## 游戏规则介绍

### 1. War（战争）纸牌游戏是什么？

War 是一个非常简单的两人纸牌游戏。

特点：

* 使用标准 **52 张扑克牌**
* 两个玩家各拿 26 张
* 不看牌
* 每轮同时翻开顶部一张牌
* 点数大的玩家赢走两张牌
* 一直玩到某个人拿走全部牌

规则类似：

```
玩家A翻牌：K
玩家B翻牌：8

K > 8

A获得两张牌
```

牌面大小：

```
A > K > Q > J > 10 > 9 > ... > 2
```

花色：

```
♠ ♥ ♦ ♣
```

不参与比较。

---

### 2. 什么叫 War（战争）？

特殊情况：

两个玩家翻出的牌一样：

例如：

```
A: 7♠
B: 7♥
```

发生 War。

双方继续下注：

例如：

```
放3张暗牌
再翻1张明牌
```

比如：

```
A:
暗 暗 暗 K

B:
暗 暗 暗 10
```

K > 10

A 赢走桌面所有牌。

## 设计

```bash
WarCardGame
│
├── Card #卡牌
│
├── Deck #Card的组合
│
├── Player #玩家
│
└── Game #游戏运行
```

## Card类

```python

In [1]: values={'Two':2, 'Three':3, 'Four':4, 'Five':5, 'Six':6, 'Seven':7, 'Eight':8, 'Nine':9, 'Ten':10, 'Jack':11,'Queen':12, 'King':13, 'Ace':14}

In [10]: suits = ('Hearts', 'Diamonds', 'Spades', 'Clubs') #花色

In [11]: ranks = ('Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Jack', 'Queen', 'King', 'Ace')

In [12]: values['King']
Out[12]: 13

In [17]: class Card:
    ...:     def __init__(self,suit,rank):
    ...:         self.suit=suit
    ...:         self.rank=rank
    ...:         self.value=values[rank]
    ...:     def __str__(self):
    ...:         return f'{self.rank} of {self.suit}'
    ...:

In [18]: two_hearts=Card("Hearts","Two")

In [19]: two_hearts.rank
Out[19]: 'Two'

In [20]: two_hearts.suit
Out[20]: 'Hearts'

In [21]: two_hearts.value
Out[21]: 2

In [22]: three_of_clubs=Card("Clubs",'Three')

In [23]: print(three_of_clubs)
Three of Clubs

In [24]: print(two_hearts)
Two of Hearts

In [25]: two_hearts.value < three_of_clubs.value
Out[25]: True
```

