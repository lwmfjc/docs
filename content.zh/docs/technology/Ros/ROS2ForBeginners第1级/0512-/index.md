---
title: "0512-"
description: "0512-"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-06T17:52:34+08:00
lastmod: 2026-10-06T17:52:34+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 活动2解决方案01

> 这一步将创建数字发布者节点
> 发布者：每秒发布一个数字
> 可以使用ros2命令行工具***验证***该发布者是否正常工作

> 下一步将制作数字计数器节点 ~~订阅者~~ 

```bash
╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg main
╰─❯ touch number_publisher.py

#查看整数相关的接口
╭─ ~/HelloROS2/ros2_ws/src main ?1
╰─❯ ros2 interface show example_interfaces/msg/Int64
# This is an example message of using a primitive datatype, int64.
# If you want to test with this that's fine, but if you are deploying
# it into a system you should create a semantically meaningful message type.
# If you want to embed it in another message, use the primitive data type instead.
int64 data
```

> `number_publisher.py`

```python
#!/usr/bin/env python3
import rclpy 
from rclpy.node import Node
from example_interfaces.msg import Int64

class NumberPublisherNode(Node):  
    def __init__(self):
        super().__init__("number_publisher")   
        self.number_=2
        #创建发布者
        #类型、名称、队列大小
        self.number_publisher_=self.create_publisher(
            Int64,"number",10
        );
        #每1.0秒调用一次
        self.number_timer=self.create_timer(1.0,self.publish_number);
        self.get_logger().info("Number publisher has been started.")
    
    def publish_number(self):
        msg=Int64()
        msg.data=self.number_
        self.number_publisher_.publish(msg)
        
def main(args=None):
    rclpy.init(args=args) 
    node=NumberPublisherNode()   
    rclpy.spin(node)
    rclpy.shutdown()

if __name__ == "__main__":
    main()

```

> 创建可执行文件

```python
entry_points={
        'console_scripts': [
            #文件夹my_py_pkg下的my_first_node.py文件
            #main是.py文件中的函数
            #py_node 是可执行文件的名称
            #可以再添加其他的可执行文件，和上面同样的格式即可
            "py_node = my_py_pkg.my_first_node:main",
            "robot_news_station = my_py_pkg.robot_news_station:main",
            "smartphone=my_py_pkg.smartphone:main",
            #仅添加这行
            "number_publisher=my_py_pkg.number_publisher:main"
        ],
    },
```

> build-->source-->run

```bash
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ colcon build --packages-select my_py_pkg --symlink-install
Starting >>> my_py_pkg
Finished <<< my_py_pkg [13.3s]

Summary: 1 package finished [13.7s]

╭─ ~/HelloROS2/ros2_ws main !1 ?1   
╰─❯ source install/setup.zsh

╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 run my_py_pkg number_publisher
[INFO] [1791288589.178232302] [number_publisher]: Number publisher has been started.


```

> 查看

```bash
#查看节点
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 node list
/number_publisher

#查看主题列表
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 topic list
/number
/parameter_events
/rosout

#订阅者
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 topic echo /number
data: 2
---
data: 2
---
data: 2
```

# 活动2解决方案02

