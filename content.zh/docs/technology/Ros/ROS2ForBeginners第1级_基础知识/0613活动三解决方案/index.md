---
title: "0613活动三解决方案"
description: "0613活动三解决方案"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-09T16:41:25+08:00
lastmod: 2026-10-09T16:41:25+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
> 在此前章节创建的数字计数节点中，添加一个新的service server

> 原先的功能，创建一个 `/number` 订阅者，订阅者收到数字后累加数据 发布累加的到 `/number_counter`

```bash
#number_counter.py
#!/usr/bin/env python3
import rclpy
from rclpy.node import Node
from example_interfaces.msg import Int64


class NumberCounterNode(Node):
    def __init__(self):
        super().__init__("number_counter")
        self.counter_ = 0
        self.number_count_publisher_ = self.create_publisher(Int64, "number_count", 10)
        # 创建订阅者
        self.number_subscriber_ = self.create_subscription(
            Int64, "number", self.callback_number, 10
        )
        self.get_logger().info("Number1 Counter has been started.")

    def callback_number(self, msg: Int64):
        # info参数必须是字符串，否则会报错
        # self.get_logger().info(str(msg.data))
        self.counter_ += msg.data
        # 在计数器更新(订阅者回调)时发布
        new_msg = Int64()
        new_msg.data = self.counter_
        self.number_count_publisher_.publish(new_msg)


def main(args=None):
    rclpy.init(args=args)
    node = NumberCounterNode()
    rclpy.spin(node)
    rclpy.shutdown()


if __name__ == "__main__":
    main()

```

> 接口定义查看

```bash
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 interface show example_interfaces/srv/SetBool
# This is an example of a service to set a boolean value.
# This can be used for testing but a semantically meaningful
# one should be created to be built upon.

bool data # e.g. for hardware enabling / disabling
---
bool success   # indicate successful run of triggered service
string message # informational, e.g. for error messages
```

# number_counter.py 修改

```python
#!/usr/bin/env python3
import rclpy
from rclpy.node import Node
from example_interfaces.msg import Int64
from example_interfaces.srv import SetBool


class NumberCounterNode(Node):
    def __init__(self):
        super().__init__("number_counter")
        self.counter_ = 0
        self.number_count_publisher_ = self.create_publisher(Int64, "number_count", 10)
        # 创建订阅者
        self.number_subscriber_ = self.create_subscription(
            Int64, "number", self.callback_number, 10
        )
        #2. 创建服务器，及其回调函数
        self.reset_counter_service_ = self.create_service(
            SetBool,
            "reset_counter",self.callback_reset_counter
        )
        self.get_logger().info("Number Counter has been started.")

    #重置计数器
    #1. 添加这个函数
    def callback_reset_counter(
        self, request: SetBool.Request, response: SetBool.Response
    ):
        #如果请求重置计数器，那么就将计数器重置为0
        if request.data:
            self.counter_=0
            response.success=True
            response.message='ok'
        else:
            response.success=False
            response.message="Counter has not been reset"
        #一定要返回响应
        return response

    def callback_number(self, msg: Int64):
        # info参数必须是字符串，否则会报错
        # self.get_logger().info(str(msg.data))
        self.counter_ += msg.data
        # 在计数器更新(订阅者回调)时发布
        new_msg = Int64()
        new_msg.data = self.counter_
        self.number_count_publisher_.publish(new_msg)


def main(args=None):
    rclpy.init(args=args)
    node = NumberCounterNode()
    rclpy.spin(node)
    rclpy.shutdown()


if __name__ == "__main__":
    main()

```

```bash
#重新构建（因为不确定上次构建是否加了--symlink-install参数）
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ colcon build --packages-select my_py_pkg --symlink-install
Starting >>> my_py_pkg
Finished <<< my_py_pkg [6.08s]

Summary: 1 package finished [6.64s]

╭─ ~/HelloROS2/ros2_ws main !1 ?1     9s
╰─❯ source install/setup.zsh


```

# 测试

```bash
#发布者：会不断发布2到主题/number
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 run my_py_pkg number_publisher
[INFO] [1791536847.037105878] [number_publisher]: Number publisher has been started.

#订阅者：把收到的/number话题的数据累加，并发布到/number_counter话题
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 run my_py_pkg number_counter
[INFO] [1791536905.135984840] [number_counter]: Number Counter has been started.

```

> 查看服务

```bash
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 service list
/number_counter/describe_parameters
/number_counter/get_parameter_types
/number_counter/get_parameters
/number_counter/get_type_description
/number_counter/list_parameters
/number_counter/set_parameters
/number_counter/set_parameters_atomically
/number_publisher/describe_parameters
/number_publisher/get_parameter_types
/number_publisher/get_parameters
/number_publisher/get_type_description
/number_publisher/list_parameters
/number_publisher/set_parameters
/number_publisher/set_parameters_atomically
#我们写的那个服务
/reset_counter

#查看接口类型
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 service type /reset_counter
example_interfaces/srv/SetBool


#查看累计数据
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 topic echo /number_count
data: 100
---
data: 102
---
data: 104
---
data: 106
---
data: 108
---
data: 110 

#调用重置计数器的服务
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 service call /reset_counter example_interfaces/srv/SetBool "{data: true}"
waiting for service to become available...
requester: making request: example_interfaces.srv.SetBool_Request(data=True)

response:
example_interfaces.srv.SetBool_Response(success=True, message='ok')

#查看重置计数器后的 /number_count 话题
#╭─ ~/HelloROS2/ros2_ws main !1 ?1
#╰─❯ ros2 topic echo /number_count
data: 100
---
data: 102
---
data: 104
---
data: 106
---
data: 108
---
data: 110 
---
data: 2
---
data: 4
---
data: 6
---
data: 8
---
data: 10
---
data: 12
---
data: 14
---
data: 16


#测试false的情况。查看 /number_count 话题：计数器没有被重置
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 service call /reset_counter example_interfaces/srv/SetBool "{data: false}"
requester: making request: example_interfaces.srv.SetBool_Request(data=False)

response:
example_interfaces.srv.SetBool_Response(success=False, message='Counter has not been reset')
```

# 总结

> 所以说一个节点中可以有许多东西，可以有发布者、订阅者、service server