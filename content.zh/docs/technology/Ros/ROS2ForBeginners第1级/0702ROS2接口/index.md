---
title: "0702ROS2接口"
description: "0702ROS2接口"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-09T17:16:08+08:00
lastmod: 2026-10-09T17:16:08+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
> 在**话题和服务**的内容中，使用了常见的**接口**在节点之间进行通信

> 对于话题，所有发布或订阅同一个话题的节点必须使用相同的数据类型

![](img/ly-20261009200655183.png)  
> 对于服务，客户端必须发送符合特定数据类型的数据，而服务器必须响应领养给也符合另一种数据类型的消息

![](img/ly-20261009200800343.png)  
话题由两件事定义

1. 名称 （`/number_count`）
2. 基于消息定义的**接口** ~~`example_interfaces/msg/Int64`~~ ，即发送消息的结构


服务由两件事定义

1. 定义名称 （`/reset_number_count`）
2. 接口，或者说服务定义 （Srv定义）(`example_interfaces/srv/SetBool`) ~~包括一个用于请求的消息定义和一个用于响应的消息定义~~ 

```bash
#一对消息
Request: msg
---
Response: msg
```

> 可以将话题和服务视为通信层工具，而接口或消息则是您实际发送的内容





