---
title: "0606-"
description: "0606-"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-08T12:08:42+08:00
lastmod: 2026-10-08T12:08:42+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
> 查看接口定义

```bash
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 interface show example_interfaces/srv/AddTwoInts
int64 a
int64 b
---
int64 sum
```

```bash
╭─ ~/HelloROS2/ros2_ws main
╰─❯ cd src/my_cpp_pkg/src

╭─ ~/HelloROS2/ros2_ws/src/my_cpp_pkg/src main
╰─❯ ls
my_first_node.cpp  robot_news_station.cpp  smartphone.cpp  template_cpp_node.cpp

╭─ ~/HelloROS2/ros2_ws/src/my_cpp_pkg/src main
╰─❯ touch add_two_ints_server.cpp
```

