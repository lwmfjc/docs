---
title: "0808活动五解决方案01"
description: "0808活动五解决方案01"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-11T21:21:12+08:00
lastmod: 2026-10-11T21:21:12+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
> 修改robot_news_station.py 运行时提供不同的机器人名称

```python
#!/usr/bin/env python3
import rclpy
from rclpy.node import Node

# 新的导入，依赖example_interfaces包
# 同时在package.xml中添加depend标签
from example_interfaces.msg import String


class MyCustomNode(Node):  
    def __init__(self):
        super().__init__("robot_news_station")  
        
        #修改下面两行即可
        self.declare_parameter("robot_name","C3PO")
        self.robot_name_ = self.get_parameter("robot_name").value

        # 创建发布者
        # 类型，话题名称，队列大小
        self.publisher_ = self.create_publisher(String, "/robot_news", 10)
        # 可以不添加斜杠，程序会自动添加
        # self.publisher_=self.create_publisher(String,"robot_news",10);
        # 添加定时器
        # 0.5秒一次，即每秒2次
        self.timer_ = self.create_timer(0.5, self.publish_news)
        self.get_logger().info("Robot News Station has been started.")

    # 发布消息
    def publish_news(self):
        msg = String()
        # msg.data="Hello"
        msg.data = "Hi, this is " + self.robot_name_ + " from the robot news station."
        self.publisher_.publish(msg)


def main(args=None):
    rclpy.init(args=args)
    node = MyCustomNode()  
    rclpy.spin(node)
    rclpy.shutdown()


if __name__ == "__main__":
    main()

```

> 测试

```bash
╭─ ~/HelloROS2/ros2_ws main !4 ?4
╰─❯ ros2 run my_py_pkg robot_news_station
[INFO] [1791725386.054079185] [robot_news_station]: Robot News Station has been started.

#参数列表
╭─ ~/HelloROS2/ros2_ws main !4 ?4
╰─❯ ros2 param list
/robot_news_station:
  robot_name
  start_type_description_service
  use_sim_time

#当前的值
╭─ ~/HelloROS2/ros2_ws main !4 ?4     4s
╰─❯ ros2 param get /robot_news_station robot_name
String value is: C3PO


╭─ ~/HelloROS2/ros2_ws main !4 ?4
╰─❯ ros2 topic list
/parameter_events
/robot_news
/rosout

╭─ ~/HelloROS2/ros2_ws main !4 ?4    17s
╰─❯ ros2 topic echo /robot_news
data: Hi, this is C3PO from the robot news station.
---
data: Hi, this is C3PO from the robot news station.
```

> 设置参数后运行

```bash
╭─ ~/HelloROS2/ros2_ws main !4 ?4
╰─❯ ros2 run my_py_pkg robot_news_station --ros-args -p robot_name:=abc
[INFO] [1791725560.380826024] [robot_news_station]: Robot News Station has been started.

╭─ ~/HelloROS2/ros2_ws main !4 ?4
╰─❯ ros2 topic echo /robot_news
data: Hi, this is abc from the robot news station.
---
data: Hi, this is abc from the robot news station.

#获取参数当前的值
╭─ ~/HelloROS2/ros2_ws main !4 ?4    30s
╰─❯ ros2 param get /robot_news_station robot_name
String value is: abc

```

> 如果参数值里有空格，需要双引号

```bash
╭─ ~/HelloROS2/ros2_ws main !4 ?4
╰─❯ ros2 run my_py_pkg robot_news_station --ros-args -p robot_name:="The Robot"   [INFO] [1791725664.777983505] [robot_news_station]: Robot News Station has been started.

╭─ ~/HelloROS2/ros2_ws main !4 ?4
╰─❯ ros2 param get /robot_news_station robot_name
String value is: The Robot
```

> 先停止上面所有

```bash
╭─ ~/HelloROS2/ros2_ws main !4 ?4
╰─❯ ros2 run my_py_pkg robot_news_station --ros-args -r __node:=station1 -p robot_name:="The Robot"
[INFO] [1791726126.364061945] [station1]: Robot News Station has been started.


╭─ ~/HelloROS2/ros2_ws main !4 ?4
╰─❯ ros2 run my_py_pkg robot_news_station --ros-args -r __node:=station2 -p robot_name:="Giskard"
[INFO] [1791726203.041923375] [station2]: Robot News Station has been started.

#订阅
╭─ ~/HelloROS2/ros2_ws main !4 ?4
╰─❯ ros2 topic echo /robot_news
data: Hi, this is The Robot from the robot news station.
---
data: Hi, this is The Robot from the robot news station.
---
data: Hi, this is Giskard from the robot news station.
---
data: Hi, this is Giskard from the robot news station.
---
data: Hi, this is Giskard from the robot news station.
---
data: Hi, this is The Robot from the robot news station.
---
data: Hi, this is Giskard from the robot news station.
```

> 展示参数

```bash
╭─ ~/HelloROS2/ros2_ws main !4 ?4
╰─❯ ros2 param list
/station1:
  robot_name
  start_type_description_service
  use_sim_time
/station2:
  robot_name
  start_type_description_service
  use_sim_time
  
#不同节点名称参数不一样
#而且只有节点存活时才存在
╭─ ~/HelloROS2/ros2_ws main !4 ?4
╰─❯ ros2 param get /station1 robot_name
String value is: The Robot

╭─ ~/HelloROS2/ros2_ws main !4 ?4     5s
╰─❯ ros2 param get /station2 robot_name
String value is: Giskard
```

