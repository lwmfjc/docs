---
title: "0806YAML参数文件"
description: "0806YAML参数文件"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-11T17:59:26+08:00
lastmod: 2026-10-11T17:59:26+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
> 将所有参数（针对一个节点甚至多个节点）保存到一个文件中，并在运行时加载该文件

`yaml /ˈjæməl/`

> 有时候参数很多，从命令行操作耗时又容易出错


```bash
#正常启动方式
╭─ ~/HelloROS2/ros2_ws main ?1
╰─❯ ros2 run my_py_pkg number_publisher --ros-args -p number:=3 -p timer_period:=1.2
[INFO] [1791723448.359648347] [number_publisher]: Number publisher has been started.

#查询节点
╭─ ~/HelloROS2/ros2_ws main ?1
╰─❯ ros2 node list
/number_publisher

#查询参数
╭─ ~/HelloROS2/ros2_ws main ?1
╰─❯ ros2 param list
/number_publisher:
  number
  start_type_description_service
  timer_period
  use_sim_time #仿真时间 #如果使用gazebo或类似的东西进行仿真，可以决定使用仿真时间启动节点
```

```bash
#该文件夹及yaml文件可以放在任何地方
╭─ ~/HelloROS2 main
╰─❯ mkdir yaml_params

╭─ ~/HelloROS2 main
╰─❯ cd yaml_params

╭─ ~/HelloROS2/yaml_params main
╰─❯ touch number_params.yaml

╭─ ~/HelloROS2/yaml_params main
╰─❯ gedit number_params.yaml

#注意下面的ros__parameters中间是两个下划线
#每隔 0.7 秒发布一次消息
#所以每秒发布 1/0.7=1.4次
╭─ ~/HelloROS2/yaml_params main ?1
╰─❯ cat number_params.yaml
/number_publisher:
  ros__parameters:
    number: 5
    timer_period: 0.7
```

> 启动节点

```bash
╭─ ~/HelloROS2/ros2_ws main ?1
╰─❯ ros2 run my_py_pkg number_publisher --ros-args --params-file /home/ly/HelloROS2/yaml_params/number_params.yaml
[INFO] [1791724052.387230823] [number_publisher]: Number publisher has been started.

#订阅话题
╭─ ~/HelloROS2/ros2_ws main ?1
╰─❯ ros2 topic echo /number
data: 5
---
data: 5
---
data: 5
```

> 速率

```bash

#每隔 0.7 秒发布一次消息
#所以每秒发布 1/0.7=1.4次
╭─ ~/HelloROS2/ros2_ws main ?1    1m 23s
╰─❯ ros2 topic hz /number
average rate: 1.429
        min: 0.699s max: 0.700s std dev: 0.00027s window: 3
average rate: 1.429
        min: 0.699s max: 0.700s std dev: 0.00029s window: 5
average rate: 1.429
        min: 0.699s max: 0.700s std dev: 0.00025s window: 7
average rate: 1.429
        min: 0.699s max: 0.700s std dev: 0.00023s window: 9
```

> 甚至可以为想加载的不同配置创建不同的yaml文件

修改number_params.yaml文件

```bash
/number_publisher1:
  ros__parameters:
    number: 5
    timer_period: 0.7
    
/number_publisher2:
  ros__parameters:
    number: 3
    timer_period: 1.0
    
```

```bash
╭─ ~/HelloROS2/ros2_ws main ?1
╰─❯ ros2 run my_py_pkg number_publisher --ros-args --params-file /home/ly/HelloROS2/yaml_params/number_params.yaml
[INFO] [1791724502.316024254] [number_publisher]: Number publisher has been started.

#由于默认节点名称为number_publisher，没在配置文件中匹配到
╭─ ~/HelloROS2/ros2_ws main ?1
╰─❯ ros2 topic echo /number
data: 2
---
data: 2
```

> 启动时修改节点名称

```bash
╭─ ~/HelloROS2/ros2_ws main ?1
╰─❯ ros2 run my_py_pkg number_publisher -r __node:=number_publisher1 --ros-args --params-file /home/ly/HelloROS2/yaml_params/number_params.yaml
[WARN] [1791724623.568178475] [rcl]: Found remap rule '__node:=number_publisher1'. This syntax is deprecated. Use '--ros-args --remap __node:=number_publisher1' instead.
[INFO] [1791724624.013044170] [number_publisher1]: Number publisher has been started.

╭─ ~/HelloROS2/yaml_params main ?1
╰─❯ ros2 topic echo /number
data: 5
---
data: 5
---
data: 5
---
data: 5
---

╭─ ~/HelloROS2/ros2_ws main ?1
╰─❯ ros2 run my_cpp_pkg number_publisher --ros-args --remap __node:=number_publisher2 --params-file /home/ly/HelloROS2/yaml_params/number_params.yaml
[INFO] [1791724763.404306941] [number_publisher2]: Number publisher has bee started.


#查看，以不同频率发布3和5
#╭─ ~/HelloROS2/yaml_params main ?1
#╰─❯ ros2 topic echo /number
data: 5
---
data: 5
---
data: 5
---
data: 5
---
data: 3
---
data: 5
---
data: 5
---
data: 3
---
data: 5

```