---
title: "0709活动四解决方案01发布消息"
description: "0709活动四解决方案01发布消息"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-10T22:02:22+08:00
lastmod: 2026-10-10T22:02:22+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---

> 该活动解决方案分成三个
> 1. 创建LED面板节点，使用自定义消息类型发布LED面板状态
> 2. 在LED面板内部创建service server，同样使用自定义服务类型
> 3. 第三个视频中是电池节点，会调用set LED服务器


![](../0602什么是ROS2Service/img/ly-20261007142657252.png)

# 创建自定义消息类型

```bash
╭─ ~/HelloROS2/ros2_ws/src/my_robot_interfaces/msg main
╰─❯ ls
HardwareStatus.msg

╭─ ~/HelloROS2/ros2_ws/src/my_robot_interfaces/msg main
╰─❯ touch LedStatusArray.msg
```

> 编辑 LedStatusArray.msg

```msg
int64[] led_status
```

> 修改`my_robot_interfaces/CMakeLists.txt`

```cmake
# 用来生成接口的命令，我们要在里面写上所有创建的接口的路径
rosidl_generate_interfaces(
	${PROJECT_NAME}
	"msg/HardwareStatus.msg" 
	"srv/ComputeRectangleArea.srv" 
	#添加这行
	"msg/LedStatusArray.msg" 
)

```

> 构建

```bash
╭─ ~/HelloROS2/ros2_ws/src/my_robot_interfaces/msg main ?1
╰─❯ cd ~/HelloROS2/ros2_ws

╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ colcon build --packages-select my_robot_interfaces
[1.345s] WARNING:colcon.colcon_core.package_selection:Some selected packages are already built in one or more underlay workspaces:
        'my_robot_interfaces' is in: /home/ly/HelloROS2/ros2_ws/install/my_robot_interfaces
If a package in a merged underlay workspace is overridden and it installs headers, then all packages in the overlay must sort their include directories by workspace order. Failure to do so may result in build failures or undefined behavior at run time.
If the overridden package is used by another package in any underlay, then the overriding package in the overlay must be API and ABI compatible or undefined behavior at run time may occur.

If you understand the risks and want to override a package anyways, add the following to the command line:
        --allow-overriding my_robot_interfaces

This may be promoted to an error in a future release of colcon-override-check.
Starting >>> my_robot_interfaces
Finished <<< my_robot_interfaces [22.7s]

Summary: 1 package finished [23.2s]

╭─ ~/HelloROS2/ros2_ws main !1 ?1    
╰─❯ source install/setup.zsh


```

> 重新打开vscode再编辑代码 ~~为了自动补全~~ 

```bash
#查看某个 ROS 2 接口包中定义的所有接口（msg/srv/action）
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 interface package my_robot_interfaces
my_robot_interfaces/msg/HardwareStatus
my_robot_interfaces/srv/ComputeRectangleArea
my_robot_interfaces/msg/LedStatusArray

#查看接口定义
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 interface show my_robot_interfaces/msg/LedStatusArray
int64[] led_status

```

# 创建节点

```bash
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ cd src/my_py_pkg/my_py_pkg/

╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg main !1 ?1
╰─❯ ls
add_two_ints_client_no_oop.py  my_first_node_dian_py.bak   __pycache__
add_two_ints_client.py         my_first_node.py            robot_news_station.py
add_two_ints_server.py         number_counter_dian_py_bak  smartphone.py
hardware_status_publisher.py   number_counter.py           template_python_node.py
__init__.py                    number_publisher.py

╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg main !1 ?1
╰─❯ touch led_panel.py
```

> led_panel.py

```python
#!/usr/bin/env python3
import rclpy
from rclpy.node import Node

# 如果没有自动补全，source后启一下vscode
from my_robot_interfaces.msg import LedStatusArray


# 需要一个发布器、一个定时器
class LEDPanelNode(Node):
    def __init__(self):
        super().__init__("led_panel")
        self.led_states_ = [0, 0, 0]
        self.led_states_pub_ = self.create_publisher(
            LedStatusArray, "led_panel_state", 10
        )
        self.led_states_timer_ = self.create_timer(5.0, self.publish_led_states)
        self.get_logger().info("LED panel node has been started.")

    def publish_led_states(self):
        msg = LedStatusArray()
        msg.led_status = self.led_states_
        self.led_states_pub_.publish(msg)


def main(args=None):
    rclpy.init(args=args)
    node = LEDPanelNode()
    rclpy.spin(node)
    rclpy.shutdown()


if __name__ == "__main__":
    main()

```

> 编辑setup.py

```python
entry_points={
        "console_scripts": [
            #  ......
            #  忽略原来的一些，不代表要删除
            "led_panel=my_py_pkg.led_panel:main"
        ],
    },
```

> build,source,run

```bash
#构建并安装功能包
╭─ ~/HelloROS2/ros2_ws main !2 ?2
╰─❯ colcon build --packages-select my_py_pkg --symlink-install
Starting >>> my_py_pkg
Finished <<< my_py_pkg [8.06s]

Summary: 1 package finished [8.52s]

╭─ ~/HelloROS2/ros2_ws main !2 ?2     
╰─❯ source install/setup.zsh

╭─ ~/HelloROS2/ros2_ws main !2 ?2
╰─❯ ros2 run my_py_pkg led_panel
[INFO] [1791678722.555519238] [led_panel]: LED panel node has been started.

```

> 自检

```bash
/parameter_events
/rosout

╭─ ~/HelloROS2/ros2_ws main !2 ?2
╰─❯ ros2 topic echo /led_panel_state
led_status:
- 0
- 0
- 0
---
led_status:
- 0
- 0
- 0


```

