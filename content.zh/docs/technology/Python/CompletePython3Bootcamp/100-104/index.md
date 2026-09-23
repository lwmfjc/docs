---
title: "100-104"
description: "100-104"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-23T13:07:32+08:00
lastmod: 2026-09-23T13:07:32+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 21点游戏项目概述

- 只有电脑庄家和人类玩家
- 从一副标准的52张牌开始
- 玩家两张明牌，庄家一张暗牌
    - 玩家目标让自己的牌面总点数 ~~当前明牌点数的和~~ 和点数比庄家更接近21
    - 玩家可以两种选择
        - hit要牌，然后计算总点数
        - stay停牌
    - 如果玩家点数低于21庄家就会不断要牌知道点数超过玩家或者庄家爆牌（点数超过21）
- 结果
    - 玩家阶段不断要牌导致超过21点，则爆牌输掉比赛
    - 玩家不断要牌直到停牌
        - 之后庄家要牌直到点数高于玩家且不超过21点则庄家获胜
        - 之后庄家要牌直到点数超过21点则庄家输掉比赛 ~~这种情况人类获胜并且赢得双倍堵注，加进赌资然后收场~~ 

> 一些特殊规则
> 1. Jack，Queen，King都算做10点
> 2. A可以算作1或11，哪个对玩家有利就算哪个


```python
In [8]: import random

In [9]:suits = ('Hearts', 'Diamonds', 'Spades', 'Clubs')

In [10]:ranks = ('Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Jack', 'Queen', 'King', 'Ace')

In [11]:values = {'Two':2, 'Three':3, 'Four':4, 'Five':5, 'Six':6, 'Seven':7, 'Eight':8, 'Nine':9, 'Ten':10, 'Jack':10,'Queen':10, 'King':10, 'Ace':11}
         
In [12]: playing=True

```

## Card

```python
In [13]: class Card:
    ...:     def __init__(self,suit,rank):
    ...:         self.suit=suit
    ...:         self.rank=rank
    ...:     def __str__(self):
    ...:         return f'{self.rank} of {self.suit}'
    ...:
```

## Deck

```python
In [14]: class Deck:
    ...:     def __init__(self):
    ...:         self.deck=[]
    ...:         for suit in suits:
    ...:             for rank in ranks:
    ...:                 self.deck.append(Card(suit,rank))
    ...:     def __str__(self):
    ...:         deck_comp=''
    ...:         for card in self.deck:
    ...:             deck_comp += '\n' + card.__str__()
    ...:         return "The deck has: " + deck_comp
    ...:     #就地洗牌
    ...:     def shuffle(self):
    ...:         random.shuffle(self.deck)
    ...:     def deal(self):
    ...:         single_card=self.deck.pop()
    ...:         return single_card
    ...:

In [15]: test_deck=Deck()

In [17]: test_deck.shuffle()

In [18]: print(test_deck)
The deck has:
Three of Diamonds
Nine of Clubs
Five of Hearts
Eight of Diamonds
Two of Hearts
Three of Spades
Five of Clubs
Queen of Clubs
Five of Spades
Ten of Hearts
King of Hearts
Four of Clubs
Seven of Diamonds
Two of Spades
Ten of Spades
Six of Spades
Ace of Clubs
Seven of Hearts
Four of Spades
Six of Hearts
Jack of Diamonds
Two of Clubs
Queen of Diamonds
Four of Hearts
Six of Clubs
King of Clubs
Queen of Hearts
Jack of Hearts
Four of Diamonds
Ten of Clubs
Eight of Hearts
Jack of Clubs
Nine of Hearts
Two of Diamonds
Three of Hearts
Seven of Clubs
Ten of Diamonds
Ace of Hearts
Queen of Spades
Eight of Clubs
Eight of Spades
Five of Diamonds
Seven of Spades
Jack of Spades
Nine of Diamonds
King of Spades
Ace of Spades
Nine of Spades
Six of Diamonds
Ace of Diamonds
Three of Clubs
King of Diamonds
#",".join(['1','2','3'])  --> 1,2,3
```

## Hand（手牌）

```python
In [26]: class Hand:
    ...:     def __init__(self):
    ...:         self.cards = []
    ...:         self.value=0
    ...:         self.aces=0
    ...:     def add_card(self,card):
    ...:         # card由 deck.deal() 获得
    ...:         self.cards.append(card)
    ...:         self.value += values[card.rank]
    ...:
    
```


> 测试

```python
In [45]: test_deck=Deck()

In [46]: test_deck.shuffle()

In [47]: test_player=Hand()

In [48]: pulled_card=test_deck.deal()

In [49]: print(pulled_card)
Queen of Clubs

In [50]: test_player.add_card(pulled_card)

In [51]: print(test_player.value)
10

In [53]: test_player.add_card(test_deck.deal())

In [55]: test_player.value
Out[55]: 20
```

> 补充：数值0为假，非零为真。空字符串为假，非空字符串为真

```python

In [1]: if 0:
   ...:     print("a")
   ...:

In [2]: if 1 and 2:
   ...:     print("b")
   ...:
b

In [3]: if '':
   ...:     print("a")
   ...:

In [4]: if 'abcde':
   ...:     print("a")
   ...:
a
```

### 处理A

```python
In [57]: class Hand:
    ...:     def __init__(self):
    ...:         self.cards = [] 
    ...:         self.value=0
    ...:         #用来跟踪Ace
    ...:         self.aces=0
    ...:     def add_card(self,card):
    ...:         # card由 deck.deal() 获得
    ...:         self.cards.append(card)
    ...:         self.value += values[card.rank]
    ...:
    ...:         if card.rank=='Ace':
    ...:             self.aces += 1
    ...:     #调整A作为1还是10的策略
    ...:     def adjust_for_ace(self):
    ...:         #很简单的策略，如果总点数大于21则调整Ace
    ...:         #表示从11变为1
    ...:         while self.value > 21 and self.aces:
    ...:             self.value -= 10
    ...:             self.aces -= 1
```
## Chip（筹码）

```python
In [59]: class Chips:
    ...:     def __init__(self,total=100):
    ...:         self.total=total
    ...:         self.bet=0
    ...:     def win_bet(self):
    ...:         self.total += self.bet
    ...:     def lose_bet(self):
    ...:         self.total -= self.bet
    ...:
```

## 实际玩游戏的一些函数

### 下注

```python
In [60]: def take_bet(chips):
    ...:     while True:
    ...:         try:
    ...:             chips.bet=int(input("下注金额?"))
    ...:         except:
    ...:             print("请输入一个整数")
    ...:         else:
    ...:             if chips.bet > chips.total:
    ...:                 print(f"抱歉，筹码不够。您只有{chips.total}")
    ...:             else:
    ...:                 break
```

### 拿牌

```python
In [61]: def hit(deck,hand):
    ...:     #从牌组拿一张牌，加入手牌
    ...:     single_card=deck.deal()
    ...:     hand.add_card(single_card)
    ...:     hand.adjust_for_ace()
    ...:
```

###  提示要牌还是停牌

```python
#可以要多次，但是这个函数只用来要一次牌
In [64]: def hit_or_stand(deck,hand):
    ...:     global playing #要修改全局变量
    ...:     #询问玩家要牌还是停牌
    ...:     while True:
    ...:         x=input('Hit or Stand? Enter h or s ')
    ...:         if x[0].lower() == 'h':
    ...:             hit(deck,hand)
    ...:         elif x[0].lower() == 's':
    ...:             print("Player Stands Dealer's Turn")
    ...:             playing=False
    ...:         else:
    ...:             print("Sorry,I dont understand,please choose s or h!")
    ...:             continue
    ...:         break
    ...:
```

### 显示牌

> 游戏开始时，装假的第一张牌是隐藏的，其余所有玩家的牌都是可见的，有两种情况，只显示庄家的第一张牌 ~~从0开始~~ 和玩家所有的牌，或者现实所有牌（包括庄家的和玩家的）

> 游戏开始时，只显示庄家第一张牌，显示玩家所有的牌

```python
In [66]: def show_some(player,dealer):
    ...:     #显示庄家的牌
    ...:     print("\n Dealer's Hand:")
    ...:     print("First card hidden!")
    ...:     print(dealer.cards[1])
    ...:     print("\n Player's hand:")
    ...:     for card in player.cards:
    ...:         print(card)
    ...:
```

> 爆牌时或者游戏结束时，显示所有的牌

```python
In [69]: def show_all(player,dealer):
    ...:     #显示所有玩家的牌
    ...:     print("\n Dealer's Hand:")
    ...:     #for card in dealer.cards:
    ...:     #    print(card)
    ...:     #会展开cards并显示，每个元素的打印后以\n分割
    ...:     print("\n Dealer's Hand:",*dealer.cards,sep='\n')
    ...:     print(f"value of dealer's hand is: {dealer.value}")
    ...:     print("\n Player's hand:")
    ...:     for card in player.cards:
    ...:         print(card)
    ...:     print(f"value of player's hand is: {player.value}")
    ...:
```

> 补充新语法

```python
In [7]: for card in items:
   ...:     print(card)
   ...:
1
2
3

In [8]: print(*items,'\n')
1 2 3


In [9]: print(*items,sep='\n')
1
2
3

#*items 写在函数调用里时，不是一个参数，而是一种展开操作。
#先展开：print("abc", 1, 2, 3, sep='\n')
In [10]: print("abc",*items,sep='\n')
abc
1
2
3
```

### 编写处理每种游戏结束情况时处理筹码的函数

> 三个参数传入：玩家，庄家，筹码

```python
#玩家爆牌
In [12]: def player_busts(player,dealer,chips):
    ...:     print("BUST PLAER!")
    ...:     chips.lose_bet()
    ...:

#玩家获胜
In [13]: def player_wins(player,dealer,chips):
    ...:     print("PLAER WINS!")
    ...:     chips.win_bet()
    ...:

#庄家爆牌
In [14]: def dealer_busts(player,dealer,chips):
    ...:     print("PLAYER WINS! BUST PLAER!")
    ...:     chips.win_bet()
    ...:

#庄家获胜
In [15]: def dealer_wins(player,dealer,chips):
    ...:     print("DEALER WINS!")
    ...:     chips.lose_bet()
    ...:

#平局
In [16]: def push(player,dealer):
    ...:     print('Dealer and plaer tie! push')
    ...:
```


## 最终游戏脚本

```python
In [27]: first_in= 1 #避免筹码重置
    ...: while True:
    ...:     print("WELCOME TO BLACKJACK")
    ...:     deck=Deck()
    ...:     deck.shuffle()
    ...:
    ...:     player_hand=Hand()
    ...:     #添加两张手牌
    ...:     player_hand.add_card(deck.deal())
    ...:     player_hand.add_card(deck.deal())
    ...:
    ...:     dealer_hand=Hand()
    ...:     #添加两张手牌
    ...:     dealer_hand.add_card(deck.deal())
    ...:     dealer_hand.add_card(deck.deal())
    ...:     #设置玩家筹码（注意！！这里每次进入循环都重置了筹码数）
    ...:     #player_chips= Chips()
    ...:     #我做了修改，避免每次筹码被重置
    ...:     player_chips= Chips() if first_in ==  1 else player_chips
    ...:     first_in=0
    ...:     #提示玩家下注
    ...:     take_bet(player_chips)
    ...:     #显示玩家、庄家的牌
    ...:     show_some(player_hand,dealer_hand)
    ...:     while playing:
    ...:         hit_or_stand(deck,player_hand)
    ...:         show_some(player_hand,dealer_hand)
    ...:         #如果超过21点
    ...:         if player_hand.value > 21:
    ...:             player_busts(player_hand,dealer_hand,player_chips)
    ...:             break
    ...:     #如果玩家没有爆牌
    ...:     if player_hand.value<=21:
    ...:         while dealer_hand.value < player_hand.value:
    ...:             hit(deck,dealer_hand)
    ...:         show_all(player_hand,dealer_hand)
    ...:         if dealer_hand.value > 21:
    ...:             dealer_busts(player_hand,dealer_hand,player_chips)
    ...:         elif dealer_hand.value > player_hand.value:
    ...:             dealer_wins(player_hand,dealer_hand,player_chips)
    ...:         elif dealer_hand.value < player_hand.value:
    ...:             player_wins(player_hand,dealer_hand,player_chips)
    ...:         else:
    ...:             push(player_hand,dealer_hand)
    ...:     print('\n Player total chips are at:{}'.format(player_chips.total))
    ...:     new_game=input("再来一场? y/n")
    ...:     if new_game[0].lower() == 'y':
    ...:         playing = True
    ...:         continue
    ...:     else:
    ...:         print("谢谢游戏！")
    ...:         break

```