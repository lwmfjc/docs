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
> 目前已经见过的两个功能

```bash
#在终端创建订阅者，并直接在终端上显示我们在该话题上接收到的内容
╭─ ~/HelloROS2/ros2_ws main !2
╰─❯ ros2 topic echo /robot_news

#显示所有话题
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 topic list
/parameter_events
/rosout
```