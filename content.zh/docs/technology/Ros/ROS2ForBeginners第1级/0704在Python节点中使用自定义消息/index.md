---
title: "0704在Python节点中使用自定义消息"
description: "0704在Python节点中使用自定义消息"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-10T15:23:22+08:00
lastmod: 2026-10-10T15:23:22+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---

> 假设我们要在ARM代码中使用刚刚创建的自定义接口（消息接口）

> 创建一个包含发布者的新节点

```bash
╭─ ~/HelloROS2/ros2_ws main
╰─❯ cd src/my_py_pkg/my_py_pkg/

╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg main
╰─❯ touch hardware_status_publisher.py
```

> 由于在Python功能包里使用了my_robot_interfaces，所以需要在package.xml中添加依赖

> package.xml

```xml
  <!--package标签中添加这个-->
  <depend>my_robot_interfaces</depend>
```

> hardware_status_publisher.py

> 创建发布者、定时器、回调函数创建消息、定时器中添加回调函数

```cpp
#!/usr/bin/env python3
import rclpy
from rclpy.node import Node

# 如果HardwareStatus自动补全识别不到，则需要关闭vscode重开
# 甚至从已经source环境的终端中 code . 启动vscode
from my_robot_interfaces.msg import HardwareStatus


class HardwareStatusPublisherNode(Node):
    def __init__(self):
        super().__init__("hardware_status_publisher")
        self.hw_status_pub_ = self.create_publisher(
            HardwareStatus, "hardware_status", 10
        )
        # 创建一个定时器，每隔 1.0 秒调用一次 publish_hw_status() 回调函数
        self.timer_ = self.create_timer(1.0,self.publish_hw_status)
        self.get_logger().info("Hw status publisher has been started.")


    def publish_hw_status(self):
        msg = HardwareStatus()
        msg.temperature = 43.7
        msg.are_motors_ready = True
        msg.debug_message = "Nothing special"
        self.hw_status_pub_.publish(msg)


def main(args=None):
    rclpy.init(args=args)
    node = HardwareStatusPublisherNode()
    rclpy.spin(node)
    rclpy.shutdown()


if __name__ == "__main__":
    main()

```

> 在setup.py里添加这个可执行文件

```python
"console_scripts": [
            # 文件夹my_py_pkg下的my_first_node.py文件
            # main是.py文件中的函数
            # py_node 是可执行文件的名称
            # 可以再添加其他的可执行文件，和上面同样的格式即可
            "py_node = my_py_pkg.my_first_node:main",
            "robot_news_station = my_py_pkg.robot_news_station:main",
            "smartphone=my_py_pkg.smartphone:main",
            "number_publisher=my_py_pkg.number_publisher:main",
            "number_counter=my_py_pkg.number_counter:main",
            "add_two_ints_server=my_py_pkg.add_two_ints_server:main",
            "add_two_ints_client_no_oop=my_py_pkg.add_two_ints_client_no_oop:main",
            "add_two_ints_client=my_py_pkg.add_two_ints_client:main",
            #添加这行
            "hw_status_publisher=my_py_pkg.hardware_status_publisher:main",
        ],
```

> 回到终端

```bash
#构建并安装功能包
╭─ ~/HelloROS2/ros2_ws main !2 ?1
╰─❯ colcon build --packages-select my_py_pkg
Starting >>> my_py_pkg
Finished <<< my_py_pkg [8.42s]

Summary: 1 package finished [8.88s]

#加载构建后的环境
╭─ ~/HelloROS2/ros2_ws main !2 ?1    
╰─❯ source install/setup.zsh

#运行
╭─ ~/HelloROS2/ros2_ws main !2 ?1
╰─❯ ros2 run my_py_pkg hw_status_publisher
[INFO] [1791623032.786440451] [hardware_status_publisher]: Hw status publisher has been started.


```

> 查询，订阅

```bash
#查询
╭─ ~/HelloROS2/ros2_ws main !2 ?1
╰─❯ ros2 node list
/hardware_status_publisher

╭─ ~/HelloROS2/ros2_ws main !2 ?1
╰─❯ ros2 topic list
/hardware_status
/parameter_events
/rosout

#要在加载环境后的终端订阅才行，否则会报错'The message type 'my_robot_interfaces/msg/HardwareStatus' is invalid'
#订阅
╭─ ~/HelloROS2/ros2_ws main !2 ?1
╰─❯ ros2 topic echo /hardware_status
temperature: 43.7
are_motors_ready: true
debug_message: Nothing special
---
temperature: 43.7
are_motors_ready: true
debug_message: Nothing special
---
temperature: 43.7
are_motors_ready: true
debug_message: Nothing special
```

