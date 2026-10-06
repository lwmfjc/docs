---
title: "0507-"
description: "0507-"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-05T19:17:12+08:00
lastmod: 2026-10-05T19:17:12+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 使用命令行工具自检ROS2话题

> 目前已经见过的两个功能

> echo：`[ˈek.əʊ]`

```bash
#在终端创建订阅者，并直接在终端上显示我们在该话题上接收到的内容
╭─ ~/HelloROS2/ros2_ws main !2
╰─❯ ros2 topic echo /robot_news

#显示所有话题
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 topic list
#这两个话题是 ROS2 自己的一些基础通信机制，一直存在的
/parameter_events #ROS 2 用来发布参数变化事件的话题
/rosout #所有节点的 ROS 日志信息汇总发布的话题。
```

> topic查询

```bash
#终端1中运行
╭─ ~/HelloROS2/ros2_ws main    ✘ 254 42s
╰─❯ ros2 run my_py_pkg robot_news_station
[INFO] [1791258424.512777119] [robot_news_station]: Robot News Station has been started.


#另一个终端2
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 topic list
/parameter_events
/robot_news #终止终端1的命令则该条消失
/rosout

╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 topic info /robot_news
Type: example_interfaces/msg/String
Publisher count: 1
Subscription count: 0
```

## 一个话题可以有多个 Publisher

```text
ros2 topic info /robot_news

Type: example_interfaces/msg/String
Publisher count: 1
Subscription count: 0
```

意思是：

> 当前 ROS 2 系统中，有 **1 个节点正在向 `/robot_news` 发布消息**，但目前没有节点订阅这个话题。

### 1. 一个话题可以有多个 Publisher

例如：

```text
             ┌── Publisher A ──┐
             │                  │
             ├── Publisher B ──┼──> /robot_news ──> Subscriber
             │                  │
             └── Publisher C ──┘
```

完全合法。

比如：

```text
节点A ──发布──┐
              │
节点B ──发布──┼──> /robot_news
              │
节点C ──发布──┘
```

三个节点都可以：

```cpp
create_publisher<String>("/robot_news", 10);
```

那么：

```text
Publisher count: 3
```

### 2. 那么消息会怎么处理？

假设：

```text
Publisher A
    │
    ├── "Hello from A"
    ↓
 /robot_news
    ↑
    ├── "Hello from B"
    │
Publisher B
```

如果有一个订阅者：

```text
                         ┌── Subscriber X
Publisher A ──┐          │
              ├──> /robot_news
Publisher B ──┘          │
                         └── Subscriber Y
```

那么 **X 和 Y 都可以收到这个 Topic 上的消息**。

但是要注意：

> Topic 并不是一个“变量”，也不是“只能由一个发布者拥有的频道”。

它更接近一个**通信名称 / 数据通道**。


### 3. 为什么 ROS 允许多个 Publisher？

因为现实中的机器人经常需要多个数据源。

例如：

```text
                    /robot_news
                         ↑
              ┌──────────┼──────────┐
              │          │          │
          摄像头节点   雷达节点   AI节点
```

当然，实际项目中通常会给它们使用不同的话题，例如：

```text
/camera/image
/lidar/scan
/ai/detection
```

但某些情况下，多个节点确实可能需要向同一个 Topic 发布。

## 直接订阅一个话题

```bash
#终端1
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 run my_py_pkg robot_news_station
[INFO] [1791259296.880872754] [robot_news_station]: Robot News Station has been started.
```

> `ros2 topic echo /robot_news`帮助我们快速了解正在发布什么，话题中发生了什么

```bash

#终端2
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 topic echo /robot_news
data: Hi, this is C3PO from the robot news station.
---
data: Hi, this is C3PO from the robot news station.
---
data: Hi, this is C3PO from the robot news station.
---
data: Hi, this is C3PO from the robot news station.

#终端3
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 topic list
/parameter_events
/robot_news
/rosout

╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 topic info /robot_news
Type: example_interfaces/msg/String
Publisher count: 1
Subscription count: 1

#显示该接口详细信息
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 interface show example_interfaces/msg/String
# This is an example message of using a primitive datatype, string.
# If you want to test with this that's fine, but if you are deploying
# it into a system you should create a semantically meaningful message type.
# If you want to embed it in another message, use the primitive data type instead.
string data
```

> 消息发布频率

```bash
#ros2 topic hz 测的是实际观察到的消息频率
╭─ ~/HelloROS2/ros2_ws main          26s
╰─❯ ros2 topic hz /robot_news
WARNING: topic [/robot_news] does not appear to be published yet
average rate: 2.000
        min: 0.499s max: 0.501s std dev: 0.00068s window: 3
average rate: 2.001
        min: 0.498s max: 0.501s std dev: 0.00093s window: 6
average rate: 2.001
        min: 0.498s max: 0.501s std dev: 0.00083s window: 8 
        
#查看带宽
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 topic bw /robot_news
Subscribed to [/robot_news]
#到目前为止收到 2 条消息，按照当前实际经过的时间（这里差不多是0.5s所以折算完才是212）折算成约 212 B/s
212 B/s from 2 messages 
#每条 /robot_news 消息的平均大小是 56 Bytes
        Message size mean: 56 B min: 56 B max: 56 B
147 B/s from 4 messages
        Message size mean: 56 B min: 56 B max: 56 B
133 B/s from 6 messages
        Message size mean: 56 B min: 56 B max: 56 B
```

> 终端发布命令（简单的）

```bash
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 topic pub -r 5 /robot_news example_interfaces/msg/String "{data: 'Hello from terminal'}"
publisher: beginning loop
publishing #1: example_interfaces.msg.String(data='Hello from terminal')

publishing #2: example_interfaces.msg.String(data='Hello from terminal')

publishing #3: example_interfaces.msg.String(data='Hello from terminal')

publishing #4: example_interfaces.msg.String(data='Hello from terminal')
```

```bash
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 topic info /robot_news
Type: example_interfaces/msg/String
Publisher count: 2
Subscription count: 0
```

## 不同发布者往同一个话题发布不同接口的消息

```bash
#终端1：'example_interfaces/msg/String'
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 run my_py_pkg robot_news_station
[INFO] [1791261367.545219247] [robot_news_station]: Robot News Station has been started.

#终端2：'example_interfaces/msg/Int32'
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 topic pub -r 5 /robot_news example_interfaces/msg/Int32 "{data: 123}"
publisher: beginning loop
publishing #1: example_interfaces.msg.Int32(data=123)

publishing #2: example_interfaces.msg.Int32(data=123) 

#终端3
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 topic info /robot_news
Type: ['example_interfaces/msg/Int32', 'example_interfaces/msg/String']
Publisher count: 2
Subscription count: 0

#终端4
#订阅者
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 topic echo /robot_news
Cannot echo topic '/robot_news', as it contains more than one type: [example_interfaces/msg/Int32, example_interfaces/msg/String]

#指定接口后就可以收到指定接口数据的订阅
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 topic echo /robot_news example_interfaces/msg/Int32
data: 123
---
data: 123
---
data: 123

#指定接口后就可以收到指定接口数据的订阅
╭─ ~/HelloROS2/ros2_ws main          52s
╰─❯ ros2 topic echo /robot_news example_interfaces/msg/String
data: Hi, this is C3PO from the robot news station.
---
data: Hi, this is C3PO from the robot news station.
```