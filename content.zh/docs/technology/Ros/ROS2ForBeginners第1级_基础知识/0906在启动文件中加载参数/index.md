---
title: "0906在启动文件中加载参数"
description: "0906在启动文件中加载参数"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-13T11:10:47+08:00
lastmod: 2026-10-13T11:10:47+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
> 本课程，将学习如何在启动文件内为节点设置参数值

> 先逐个设置参数；然后直接从yaml文件加载

# 回顾

```bash
╭─ ~/HelloROS2/ros2_ws main !2
╰─❯ ros2 run my_py_pkg number_publisher --ros-args -p number:=7
[INFO] [1791862961.119420609] [number_publisher]: Number publisher has been started.

#节点number_publisher有两个参数 number 和 timer_period
╭─ ~/HelloROS2/ros2_ws main !2      
╰─❯ ros2 param list
/number_publisher:
  number
  start_type_description_service
  timer_period
  use_sim_time

╭─ ~/HelloROS2/ros2_ws main !2
╰─❯ ros2 topic echo /number
data: 7
---
data: 7

```

# 使用param标签设置参数

> 修改number_app_launch.xml

```xml
<launch>
    <!--所有的内容都放在这个launch中-->
    <!--name 修改节点名称-->
    <node pkg="my_py_pkg" exec="number_publisher" name="my_number_publisher">
        <!-- 重映射话题名称，对服务也有效果 -->
        <remap from="/number" to="/my_number" />
        <!-- 设置参数：新增下面两行 -->
        <param name="number" value="6" />
        <param name="timer_period" value="1.5" />
    </node>
    <node pkg="my_cpp_pkg" exec="number_counter" name="my_number_counter">
        <remap from="/number" to="/my_number" />
    </node>
</launch>
```

> build,source,launch

```bash
╭─ ~/HelloROS2/ros2_ws main !2
╰─❯ colcon build --packages-select my_robot_bringup
Starting >>> my_robot_bringup
Finished <<< my_robot_bringup [2.12s]

Summary: 1 package finished [2.57s]

╭─ ~/HelloROS2/ros2_ws main !2                                                    4s
╰─❯ source install/setup.zsh

╭─ ~/HelloROS2/ros2_ws main !2
╰─❯ ros2 launch my_robot_bringup number_app.launch.xml
[INFO] [launch]: All log files can be found below /home/ly/.ros/log/2026-10-13-11-53-17-078247-ubt24-1-13640
[INFO] [launch]: Default logging verbosity is set to INFO
[INFO] [number_publisher-1]: process started with pid [13643]
[INFO] [number_counter-2]: process started with pid [13644]
[number_counter-2] [INFO] [1791863597.870359912] [my_number_counter]: Number counter has been started.
[number_publisher-1] [INFO] [1791863599.238838502] [my_number_publisher]: Number publisher has been started.
```

> 查看结果

```bash
╭─ ~/HelloROS2/ros2_ws main !2
╰─❯ ros2 topic echo /my_number
data: 6
---
data: 6


#注意这里 param还是number，只是话题名称重映射成了 /my_number
╭─ ~/HelloROS2/ros2_ws main !2     
╰─❯ ros2 param list
/my_number_counter:
  qos_overrides./parameter_events.publisher.depth
  qos_overrides./parameter_events.publisher.durability
  qos_overrides./parameter_events.publisher.history
  qos_overrides./parameter_events.publisher.reliability
  start_type_description_service
  use_sim_time
/my_number_publisher:
  number
  start_type_description_service
  timer_period
  use_sim_time
```

> 查看参数，发布频率

```bash
╭─ ~/HelloROS2/ros2_ws main !2
╰─❯ ros2 param get /my_number_publisher number
Integer value is: 6

╭─ ~/HelloROS2/ros2_ws main !2
╰─❯ ros2 param get /my_number_publisher timer_period
Double value is: 1.5

╭─ ~/HelloROS2/ros2_ws main !2
╰─❯ ros2 topic hz /my_number
average rate: 0.666
        min: 1.502s max: 1.503s std dev: 0.00011s window: 2
average rate: 0.667
        min: 1.493s max: 1.503s std dev: 0.00429s window: 3
^C%                                                                                  
```

# 使用yaml文件

```bash

```