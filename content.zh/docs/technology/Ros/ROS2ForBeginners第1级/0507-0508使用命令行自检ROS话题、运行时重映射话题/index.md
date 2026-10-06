---
title: "0507-0508使用命令行自检ROS话题、运行时重映射话题"
description: "0507-0508使用命令行自检ROS话题、运行时重映射话题"
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

> 目前留下 python 发布者和终端 Int 接口发布者，以及String订阅者

```bash
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 node list
/robot_news_station

#注意，这里查看的是节点，不是话题。这里只查看了节点robot_news_station即Python文件的那个节点
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 node info /robot_news_station
/robot_news_station
  Subscribers:

  Publishers:
    /parameter_events: rcl_interfaces/msg/ParameterEvent
    /robot_news: example_interfaces/msg/String
    /rosout: rcl_interfaces/msg/Log
  Service Servers:
    /robot_news_station/describe_parameters: rcl_interfaces/srv/DescribeParameters
    /robot_news_station/get_parameter_types: rcl_interfaces/srv/GetParameterTypes
    /robot_news_station/get_parameters: rcl_interfaces/srv/GetParameters
    /robot_news_station/get_type_description: type_description_interfaces/srv/GetTypeDescription
    /robot_news_station/list_parameters: rcl_interfaces/srv/ListParameters
    /robot_news_station/set_parameters: rcl_interfaces/srv/SetParameters
    /robot_news_station/set_parameters_atomically: rcl_interfaces/srv/SetParametersAtomically
  Service Clients:

  Action Servers:

  Action Clients:

#查看包含命令行终端的节点
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 node list --all
/_ros2cli_10176
/_ros2cli_9892
/_ros2cli_9926
/_ros2cli_daemon_0_2a43380bfe90493e9a922f28c326d5bc
/robot_news_station

#没法info
#视频无涉及  #未解决
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 node info /_ros2cli_9926
Unable to find node '/_ros2cli_9926'


```

# 运行时重映射话题

> 重命名节点

```bash
╭─ ~/HelloROS2/ros2_ws main    
╰─❯ ros2 run my_py_pkg robot_news_station --ros-args -r __node:=my_station
[INFO] [1791268049.820546066] [my_station]: Robot News Station has been started.

╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 node list
/my_station
```

```bash
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 topic list
/parameter_events
/robot_news
/rosout
```

> 重命名话题

```bash
#即源代码中指定的话题名称，可以在运行时被修改
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 run my_py_pkg robot_news_station --ros-args -r __node:=my_station -r robot_news:=abc
[INFO] [1791268172.616566718] [my_station]: Robot News Station has been started.

╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 topic list
/abc
/parameter_events
/rosout

─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 topic echo /abc
data: Hi, this is C3PO from the robot news station.
---
data: Hi, this is C3PO from the robot news station.
```

> 收不到信息

```bash
#即使这里是有/robot_news 话题的
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 topic list
/abc
/parameter_events
/robot_news
/rosout

╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 run my_py_pkg smartphone
[INFO] [1791268330.773893759] [smartphone]: Smartphone has been started.

#查看话题相关信息
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 topic info /abc
Type: example_interfaces/msg/String
Publisher count: 1
Subscription count: 1

╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 topic info /robot_news
Type: example_interfaces/msg/String
Publisher count: 0
Subscription count: 1

```

> 如果想要接收信息，我们需要对话题进行重映射

> 如果你需要匹配不同人员编写的不同节点，或者无法访问代码且无法在代码中修改话题名称，那么可以在运行时重映射话题名称

```bash
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 run my_py_pkg smartphone --ros-args -r robot_news:=abc
[INFO] [1791268544.121223508] [smartphone]: Smartphone has been started.
[INFO] [1791268544.124806506] [smartphone]: Hi, this is C3PO from the robot news station.
[INFO] [1791268544.575512695] [smartphone]: Hi, this is C3PO from the robot news station.
[INFO] [1791268545.074534492] [smartphone]: Hi, this is C3PO from the robot news station. 
```

### 原理

这里关键是你把 **“代码里的话题名”** 和 **“ROS 2 运行时最终使用的话题名”** 混在了一起。

你执行的是：

```bash
ros2 run my_py_pkg smartphone --ros-args -r robot_news:=abc
```

其中：

```bash
-r robot_news:=abc
```

不是修改你的 Python 源代码，而是告诉 **ROS 2：运行这个节点时，把 `robot_news` 这个名字重映射（remap）成 `abc`。**

#### 1. 假设你的代码是这样

```python
self.subscriber_ = self.create_subscription(
    String,
    "robot_news",
    self.callback_robot_news,
    10
)
```

代码写死的是：

```text
robot_news
```

正常情况下：

```text
smartphone
   │
   │ 订阅
   ▼
/robot_news
```

#### 2. 但是你启动时加了 remap

```bash
--ros-args -r robot_news:=abc
```

ROS 2 在创建节点的时候，会看到：

```text
代码要求订阅：robot_news
```

然后根据启动参数：

```text
robot_news → abc
```

于是**最终这个节点实际订阅的是 `abc`**。

可以理解成：

```text
Python代码
    │
    │ create_subscription("robot_news", ...)
    ▼
ROS 2名称解析/重映射
    │
    │ robot_news → abc
    ▼
实际订阅
    │
    ▼
/abc
```

所以你代码完全没变。

#### 3. 为什么 ROS 2 能做到这一点？

因为：

```python
create_subscription(...)
```

并不是直接让 Python 去操作某个叫 `robot_news` 的底层通信通道。

它实际上是在告诉 ROS 2：

> “我要创建一个订阅者，它的**原始名称**是 `robot_news`。”

ROS 2 创建这个订阅者时，会经过 **name remapping（名称重映射）**。

所以可以把它粗略理解成：

```text
代码指定的名字
        ↓
    ROS 2处理
        ↓
  检查有没有remap规则
        ↓
      有 → 修改
      无 → 保持
        ↓
实际创建订阅
```

#### 4. 这有什么用？

这个功能非常重要。

比如你的程序写的是：

```python
"robot_news"
```

你可以启动两个 smartphone：

```bash
ros2 run my_py_pkg smartphone --ros-args -r robot_news:=abc
```

另一个：

```bash
ros2 run my_py_pkg smartphone --ros-args -r robot_news:=xyz
```

那么两个**完全相同的程序**：

```text
smartphone #1
    ↓
订阅 /abc


smartphone #2
    ↓
订阅 /xyz
```

代码甚至完全不用修改。

这就是 ROS 2 的 **Remapping（名称重映射）**。

#### 5. 你这里还有一个容易误解的地方

你说：

> “修改订阅者指定的话题名称”

更准确地说，不是：

> 修改订阅者

而是：

> **修改这个订阅者所使用的 topic name。**

订阅者仍然是：

```text
smartphone
```

只是：

```text
原始 topic name：
robot_news

↓ remap

实际 topic name：
abc
```

你可以直接验证：

```bash
ros2 node info /smartphone
```

应该能看到类似：

```text
Subscribers:
    /abc: example_interfaces/msg/String
```

而不是：

```text
/robot_news
```

这也是为什么 **ROS 2 的代码可以写一个通用节点，然后通过启动参数决定它到底连接哪个话题**。这在实际机器人系统里非常常见。

