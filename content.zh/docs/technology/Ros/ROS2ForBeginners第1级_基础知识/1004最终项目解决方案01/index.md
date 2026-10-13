---
title: "1004最终项目解决方案01"
description: "1004最终项目解决方案01"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-13T17:24:01+08:00
lastmod: 2026-10-13T17:24:01+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---

> 第一步，让海龟动起来，即启动海龟模拟器，让海龟到达地图上的某个特定点

# 先启动海龟模拟器，查看话题、服务

```bash
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 run turtlesim turtlesim_node
WARNING: CPU random generator seem to be failing, disabling hardware random number generation
WARNING: RDRND generated: 0xffffffff 0xffffffff 0xffffffff 0xffffffff
[INFO] [1791886647.611726565] [turtlesim]: Starting turtlesim with node name /turtlesim
[INFO] [1791886647.692924833] [turtlesim]: Spawning turtle [turtle1] at x=[5.544445], y=[5.544445], theta=[0.000000]


```

```bash
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 topic list
/parameter_events
/rosout
/turtle1/cmd_vel #给 turtle1 发送速度指令
/turtle1/color_sensor
/turtle1/pose  #海龟当前的位置和姿态信息
```

```bash
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 topic echo /turtle1/pose
x: 5.544444561004639 #居中的时候是(5.5,5.5)，所有最大值右上角最远应该是(11,11)
y: 5.544444561004639
theta: 0.0 #意味着指向正右侧，从正右侧往上往左最多旋转360回到原来的方向
linear_velocity: 0.0
angular_velocity: 0.0
---
x: 5.544444561004639
y: 5.544444561004639
theta: 0.0
linear_velocity: 0.0
angular_velocity: 0.0

╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 topic hz /turtle1/pose
average rate: 62.518 #1秒钟62次
        min: 0.014s max: 0.018s std dev: 0.00076s window: 64
average rate: 62.503
        min: 0.012s max: 0.019s std dev: 0.00098s window: 127
average rate: 62.479
        min: 0.011s max: 0.022s std dev: 0.00107s window: 190
```

```bash

```

> rqt图查看

![](img/ly-20261013212115894.png)  

> 如图，右边那些方框的话题都属于`/turtle1`命名空间

![](img/ly-20261013212233340.png)  

总结一下 /turtlesim 在这个图中的角色：

- 作为订阅者：订阅 `/turtle1/cmd_vel`（接收速度指令）。
- 作为发布者：发布 `/turtle1/pose`（位姿）、/turtle1/color_sensor（颜色传感器数据）、以及 Action 的反馈和状态信息。

> 我们会使用`/turtle1/cmd_vel` 和 `/turtle1/pose` ，我们将获取当前位置，然后根据该位置发送新的命令速度

# 节点编写

