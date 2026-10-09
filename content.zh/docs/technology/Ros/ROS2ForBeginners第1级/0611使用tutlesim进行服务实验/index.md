---
title: "0611使用tutlesim进行服务实验"
description: "0611使用tutlesim进行服务实验"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-09T12:35:33+08:00
lastmod: 2026-10-09T12:35:33+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
```bash
#启动小乌龟gui
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 run turtlesim turtlesim_node
WARNING: CPU random generator seem to be failing, disabling hardware random number generation
WARNING: RDRND generated: 0xffffffff 0xffffffff 0xffffffff 0xffffffff
[INFO] [1791522339.122474523] [turtlesim]: Starting turtlesim with node name /turtlesim
[INFO] [1791522339.174964115] [turtlesim]: Spawning turtle [turtle1] at x=[5.544445], y=[5.544445], theta=[0.000000]

```

![](img/ly-20261009130617922.png)  

```bash
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 service list

#启动键盘控制的service
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 run turtlesim turtle_teleop_key
 Reading from keyboard
---------------------------
Use arrow keys to move the turtle.
Use g|b|v|c|d|e|r|t keys to rotate to absolute orientations. 'f' to cancel a rotation.
'q' to quit.

╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 run turtlesim turtle_teleop_key
Reading from keyboard
---------------------------
Use arrow keys to move the turtle.
Use g|b|v|c|d|e|r|t keys to rotate to absolute orientations. 'f' to cancel a rotation.
'q' to quit.
```

```bash
#另一个终端查看服务
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 service list
/clear
/kill
/reset
/spawn
/teleop_turtle/describe_parameters
/teleop_turtle/get_parameter_types
/teleop_turtle/get_parameters
/teleop_turtle/get_type_description
/teleop_turtle/list_parameters
/teleop_turtle/set_parameters
/teleop_turtle/set_parameters_atomically
/turtle1/set_pen
/turtle1/teleport_absolute
/turtle1/teleport_relative
/turtlesim/describe_parameters
/turtlesim/get_parameter_types
/turtlesim/get_parameters
/turtlesim/get_type_description
/turtlesim/list_parameters
/turtlesim/set_parameters
/turtlesim/set_parameters_atomically

```