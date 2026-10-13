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

> 创建 `src/my_robot_bringup/config` 文件夹

```bash

╭─ ~/HelloROS2/ros2_ws main
╰─❯ cd src/my_robot_bringup/

╭─ ~/HelloROS2/ros2_ws/src/my_robot_bringup main
╰─❯ ls
CMakeLists.txt  launch  package.xml

╭─ ~/HelloROS2/ros2_ws/src/my_robot_bringup main
╰─❯ mkdir config
```

> 修改CMakeLists.txt文件，在install中添加config路径

> 任何希望在"my_robot_bringup"中添加并希望安装新的文件夹，只需加一个空格然后放上文件夹名字即可

```cmake
#提供指令：想要安装launch文件夹，以及launch文件夹
#内的所有内容
install(DIRECTORY
  launch config
  # 将launch目录安装到 install/<package_name>/share/<package_name>/ 下
  DESTINATION share/${PROJECT_NAME}/
) 

```

> 添加 `config/number_app.yaml`

```bash
╭─ ~/HelloROS2/ros2_ws/src/my_robot_bringup main
╰─❯ tree
.
├── CMakeLists.txt
├── config
│   └── number_app.yaml #添加这个yaml文件即可
├── launch
│   ├── number_app_from_python.lauch.xml
│   ├── number_app.launch.py
│   └── number_app.launch.xml
└── package.xml

3 directories, 6 files
```

> 修改 number_app.yaml  ~~和之前的语法一致~~ 

```bash
╭─ ~/HelloROS2/ros2_ws/src/my_robot_bringup main !1 ?1
╰─❯ cat config/number_app.yaml
/my_number_publisher:
  ros__parameters:
    number: 6
    timer_period: 1.5
```

> 修改 number_app_launch.xml

```xml
<launch>
    <!--所有的内容都放在这个launch中-->
    <!--name 修改节点名称-->
    <node pkg="my_py_pkg" exec="number_publisher" name="my_number_publisher">
        <!-- 重映射话题名称，对服务也有效果 -->
        <remap from="/number" to="/my_number" />

        <!--在xml启动文件中包含param文件-->
        <param from="$(find-pkg-share my_robot_bringup)/config/number_app.yaml" />

        <!-- <param name="number" value="6" />
        <param name="timer_period" value="1.5" /> -->
    </node>
    <node pkg="my_cpp_pkg" exec="number_counter" name="my_number_counter">
        <remap from="/number" to="/my_number" />
    </node>
</launch>
```

> 测试

```bash
╭─ ~/HelloROS2/ros2_ws main !3 ?1
╰─❯ colcon build --packages-select my_robot_bringup
Starting >>> my_robot_bringup
Finished <<< my_robot_bringup [3.31s]

Summary: 1 package finished [3.84s]

╭─ ~/HelloROS2/ros2_ws main !3 ?1     
╰─❯ source install/setup.zsh

╭─ ~/HelloROS2/ros2_ws main !3 ?1
╰─❯ ros2 launch my_robot_bringup number_app.launch.xml
[INFO] [launch]: All log files can be found below /home/ly/.ros/log/2026-10-13-13-11-47-540093-ubt24-1-18839
[INFO] [launch]: Default logging verbosity is set to INFO
[WARNING] [launch_ros.actions.node]: Parameter file path is not a file: ${find-pkg-share my_robot_bringup}/config/number_app.yaml
[INFO] [number_publisher-1]: process started with pid [18848]
[INFO] [number_counter-2]: process started with pid [18849]
[number_counter-2] [INFO] [1791868308.637210148] [my_number_counter]: Number counter has been started.
[number_publisher-1] [INFO] [1791868309.715792581] [my_number_publisher]: Number publisher has been started.


╭─ ~/HelloROS2/ros2_ws main !3 ?1
╰─❯ ros2 param get /my_number_publisher number
Integer value is: 6
```

# 在 python文件中使用参数设置

> 修改number_app.launch.py

```bash
from launch import LaunchDescription
from launch_ros.actions import Node


# 固定的generate_launch_description名字
def generate_launch_description():
    ld = LaunchDescription()

    # 创建一个启动节点对象
    number_publisher = Node(
        package="my_py_pkg",
        executable="number_publisher",
        name="my_number_publisher",
        #元组列表，为每个需要的重映射提供一个元组
        remappings=[("/number", "/my_number")],
        #添加下面两行，设置参数
        parameters=[
            {"number": 12},
            {"timer_perior": 1.3}
        ]
    )

    # 创建一个启动节点对象
    number_counter = Node(
        package="my_cpp_pkg",
        executable="number_counter",
        name="my_number_counter",
        remappings=[("/number", "/my_number")],
    )

    # 添加到LaunchDescription中
    ld.add_action(number_publisher)
    ld.add_action(number_counter)

    return ld

```

> build,source,launch

```bash

╭─ ~/HelloROS2/ros2_ws main !3 ?1
╰─❯ colcon build --packages-select my_robot_bringup
Starting >>> my_robot_bringup
Finished <<< my_robot_bringup [1.95s]

Summary: 1 package finished [2.49s]

╭─ ~/HelloROS2/ros2_ws main !4 ?1    
╰─❯ source install/setup.zsh

╭─ ~/HelloROS2/ros2_ws main !4 ?1
╰─❯ ros2 launch my_robot_bringup number_app.launch.py
[INFO] [launch]: All log files can be found below /home/ly/.ros/log/2026-10-13-13-34-20-725442-ubt24-1-21080
[INFO] [launch]: Default logging verbosity is set to INFO
[INFO] [number_publisher-1]: process started with pid [21083]
[INFO] [number_counter-2]: process started with pid [21084]
[number_counter-2] [INFO] [1791869661.218954598] [my_number_counter]: Number counter has been started.
[number_publisher-1] [INFO] [1791869662.391908454] [my_number_publisher]: Number publisher has been started.


#查看参数值
╭─ ~/HelloROS2/ros2_ws main !4 ?1
╰─❯ ros2 param get /my_number_publisher number
Integer value is: 12
```

# 在Python文件中使用yaml文件

```python
from launch import LaunchDescription
from launch_ros.actions import Node
#获取包共享目录
#修改此处
from ament_index_python.packages import get_package_share_directory
#修改此处
import os


# 固定的generate_launch_description名字
def generate_launch_description():
    ld = LaunchDescription()

    #修改此处
    param_config=os.path.join(get_package_share_directory("my_robot_bringup"),"config","number_app.yaml")

    # 创建一个启动节点对象
    number_publisher = Node(
        package="my_py_pkg",
        executable="number_publisher",
        name="my_number_publisher",
        #元组列表，为每个需要的重映射提供一个元组
        remappings=[("/number", "/my_number")],
        # parameters=[
        #     {"number": 12},
        #     {"timer_perior": 1.3}
        # ]
        #修改此处
        parameters=[param_config]
    )

    # 创建一个启动节点对象
    number_counter = Node(
        package="my_cpp_pkg",
        executable="number_counter",
        name="my_number_counter",
        remappings=[("/number", "/my_number")],
    )

    # 添加到LaunchDescription中
    ld.add_action(number_publisher)
    ld.add_action(number_counter)

    return ld

```

> build,source,launch

```bash
╭─ ~/HelloROS2/ros2_ws main !4 ?1      
╰─❯ colcon build --packages-select my_robot_bringup
Starting >>> my_robot_bringup
Finished <<< my_robot_bringup [2.24s]

Summary: 1 package finished [2.79s]

╭─ ~/HelloROS2/ros2_ws main !4 ?1      
╰─❯ source install/setup.zsh

╭─ ~/HelloROS2/ros2_ws main !4 ?1
╰─❯ ros2 launch my_robot_bringup number_app.launch.py
[INFO] [launch]: All log files can be found below /home/ly/.ros/log/2026-10-13-13-38-55-647074-ubt24-1-21529
[INFO] [launch]: Default logging verbosity is set to INFO
[INFO] [number_publisher-1]: process started with pid [21532]
[INFO] [number_counter-2]: process started with pid [21533]
[number_counter-2] [INFO] [1791869936.179590355] [my_number_counter]: Number counter has been started.
[number_publisher-1] [INFO] [1791869937.148371086] [my_number_publisher]: Number publisher has been started.
```

> 查看参数值

```bash
╭─ ~/HelloROS2/ros2_ws main !4 ?1
╰─❯ ros2 param get /my_number_publisher number
Integer value is: 6

```