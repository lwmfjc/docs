---
title: "0809活动五解决方案02"
description: "0809活动五解决方案02"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-11T21:47:17+08:00
lastmod: 2026-10-11T21:47:17+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
> self.led_states 默认状态为 `[0,0,0]`。我们要做的是在启动节点时为该数组提供不同的配置

> 修改 led_panel.py 

```bash
        #修改__init__函数中 self.led_states_的设置部分即可
        self.declare_parameter("led_states", [0, 0, 0])
        self.led_states_ = self.get_parameter("led_states").value
```

> 运行


```bash
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 run my_py_pkg led_panel
[INFO] [1791772893.130958177] [led_panel]: LED panel node has been started.


#查询
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 node list
/led_panel

╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 param list
/led_panel:
  led_states
  start_type_description_service
  use_sim_time

#参数当前值（是默认值）
╭─ ~/HelloROS2/ros2_ws main !1 ?1     3s
╰─❯ ros2 param get /led_panel led_states 
Integer values are: [0, 0, 0]

╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 topic echo /led_panel_state
led_states:
- 0
- 0
- 0
---
led_states:
- 0
- 0
- 0
```

> 给参数默认值

```bash
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 run my_py_pkg led_panel --ros-args -p led_states:='[0,0,0,0,1]'
[INFO] [1791773235.995108605] [led_panel]: LED panel node has been started.

╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 param list
/led_panel:
  led_states
  start_type_description_service
  use_sim_time

╭─ ~/HelloROS2/ros2_ws main !1 ?1     4s
╰─❯ ros2 param get /led_panel led_states
Integer values are: [0, 0, 0, 0, 1]


╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 topic  echo /led_panel_state
led_states:
- 0
- 0
- 0
- 0
- 1
---
led_states:
- 0
- 0
- 0
- 0
- 1
```

> 这里有个问题，参数数组里的值可能不会是0或1（因为代码中没有校验） ~~这里目前不处理~~ 

> 使用yaml参数文件

```bash
#新增文件并编辑保存
╭─ ~/HelloROS2/yaml_params main !1 ?2
╰─❯ cat led_config.yaml
/led_panel:
  ros__parameters:
    led_states: [0,0,0,3]
    
```

> 使用yaml文件

```bash
╭─ ~/HelloROS2 main !1 ?2
╰─❯ ros2 run my_py_pkg led_panel --ros-args --params-file /home/ly/HelloROS2/yaml_params/led_config.yaml
[INFO] [1791773713.440194834] [led_panel]: LED panel node has been started.

╭─ ~/HelloROS2/ros2_ws main !1 ?2
╰─❯ ros2 param get /led_panel led_states
Integer values are: [0, 0, 0, 3]

```