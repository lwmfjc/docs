---
title: 070-073
description: 070-073
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-19T22:02:03+08:00
lastmod: 2026-09-19T22:02:03+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 里程碑项目概述

```
#才用数字小键盘的概念，修改九宫格某一个位置的值
7  8  9
4  5  6
1  2  3
```

## 显示棋盘

```python
import os
In [2]: def display_board(board):
    ...:     #os.system('cls' if os.name == 'nt' else 'clear')
    ...:     print('\n\n\n\n\n\n\n')
    ...:     print(board[7]+'|'+board[8]+'|'+board[9])
    ...:     print(board[4]+'|'+board[5]+'|'+board[6])
    ...:     print(board[1]+'|'+board[2]+'|'+board[3])

In [3]: test_board=['#','X','O','X','O','X','O','X','O','X']

In [4]: display_board(test_board)
X|O|X
O|X|O
X|O|X
```

这里还用了`from IPython.display import clear_output`以及`clear_output()` 来清屏，但是我没效果  

使用`%clear` 或者 

```python
import os

os.system('cls' if os.name == 'nt' else 'clear')
```

## 玩家选择标识符

```python
In [21]: def player_input():
    ...:     marker=''
    ...:     while marker not in ['X','O']:
    ...:         marker=input('Player1 choose "X" or "O":').upper()
    ...:     if marker == 'X':
    ...:         return ('X','O')
    ...:     else:
    ...:         return ('O','X')
    ...:

In [22]: player_input()
Player1 choose "X" or "O":s
Player1 choose "X" or "O":o
Out[22]: ('O', 'X')
```

## 标记棋盘

```python
In [26]: def place_marker(board,marker,position):
    ...:     board[position]=marker
    ...:

In [27]: place_marker(test_board,'$',8)

In [30]: display_board(test_board)
X|$|X
O|X|O
X|O|X
```

## 检查是否有人胜出

```python
In [35]: def win_check(board,mark):
    ...:     #所有行
    ...:     return ((board[1]==mark and board[2]== mark and board[3] == mark) or
    ...:     (board[4]== board[5]== board[6] == mark) or
    ...:     (board[7]== board[8]== board[9] == mark) or
    ...:     #所有列
    ...:     (board[1]== board[4]== board[7] == mark) or
    ...:     (board[2]== board[5]== board[8] == mark) or
    ...:     (board[3]== board[6]== board[9] == mark) or
    ...:     #对角线
    ...:     (board[1]== board[5]== board[9] == mark) or
    ...:     (board[3]== board[5]== board[7] == mark)
    ...:     )
    ...:
```

## 决定哪个玩家先走

```python
import random
In [41]: def choose_first():
    ...:     flip=random.randint(0,1)
    ...:     if flip == 0:
    ...:         return 'Player 1'
    ...:     else:
    ...:         return 'Player 2'
```

## 指示棋盘某个空间是否空闲

```python
In [48]: def space_check(board,position):
    ...:     return ( board[position]== ' ')
    ...:

```

## 棋盘是否填满

```python
In [49]: def full_board_check(board):
    ...:     for i in range(1,10):
    ...:         if space_check(board,i):
    ...:             return False
    ...:     return True
    ...:
```

## 玩家选择位置

```python
In [50]: def player_choice(board):
    ...:     position=0
    ...:     #position不在0-9范围，或者该位置不是空闲的(已被选择)
    ...:     while position not in range(1,10) or not space_check(board,position):
    ...:         position=int(input('choose a position:(1-9)'))
    ...:     return position
    ...:
```

## 询问玩家是否要再玩一次

```python
In [51]: def replay():
    ...:     choice=input('play again?enter yes or no')
    ...:     return choice == 'yes'
    ...:
```

## 整合（所有逻辑代码）

```python
#通过while循环保持游戏运行
print('Welcome to Tic TAC TOE')

while True:
        #玩游戏
        #设置环境（棋盘、谁先走、选择棋子 X，O）
        the_board=[' ']*10
        player1_marker,player2_marker=player_input()
        turn=choose_first()
        print(turn+' will go first')
        play_game=input('Ready to play? y or no? ')
        if play_game=='y':
                game_on = True
        else:
                game_on = False
        while game_on:         
                #玩家一、玩家二的回合      
                #游戏开始
                #区分是玩家一的回合还是玩家二的回合
                if turn == 'Player 1':
                        display_board(the_board) 
                        #选择位置、放置棋子
                        position=player_choice(the_board)
                        place_marker(the_board,player1_marker,position)
                        if win_check(the_board,player1_marker):
                            display_board(the_board)
                            print('player 1  has won!')
                            game_on=False
                        else:
                            if full_board_check(the_board):
                                display_board(the_board)
                                print("TIE game")
                                game_on=False
                            else:
                                turn = 'Player 2'
                #玩家二的回合
                else:
                        display_board(the_board) 
                        #选择位置、放置棋子
                        position=player_choice(the_board)
                        place_marker(the_board,player2_marker,position)
                        if win_check(the_board,player2_marker):
                            display_board(the_board)
                            print('player 2  has won!')
                            game_on=False
                        else:
                            if full_board_check(the_board):
                                display_board(the_board)
                                print("TIE game")
                                game_on=False
                            else:
                                turn = 'Player 1'
        if not replay():
             break
        #不重玩了就跳出循环
```