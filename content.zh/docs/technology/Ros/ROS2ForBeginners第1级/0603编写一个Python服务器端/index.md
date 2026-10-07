---
title: "0603编写一个Python服务器端"
description: "0603编写一个Python服务器端"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-07T14:53:57+08:00
lastmod: 2026-10-07T14:53:57+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 编写一个Python服务器端

> 创建一个服务器，接收两个数字作为请求，并返回他们的和作为响应

> 服务是由名称和接口共同定义的

> 一个服务将包含两条消息，一个是请求，一个是响应

> 从客户端需要发送a和b，然后在服务端接受它们
> 服务器返回带有sum的响应

```bash
#破折号上下分别是两个不同的消息
╭─ ~/HelloROS2 main
╰─❯ ros2 interface show example_interfaces/srv/AddTwoInts
int64 a
int64 b
---
int64 sum
```

> 还是在my_py_pkg这个包中，创建文件

```bash
╭─ ~/HelloROS2 main
╰─❯ cd ros2_ws/src/my_py_pkg/my_py_pkg

╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg main
╰─❯ ls
__init__.py                number_counter.py    robot_news_station.py
my_first_node_dian_py.bak  number_publisher.py  smartphone.py
my_first_node.py           __pycache__          template_python_node.py

╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg main
╰─❯ touch add_two_ints_server.py
```

## add_two_ints_server.py

```python
#!/usr/bin/env python3
import rclpy
from rclpy.node import Node
from example_interfaces.srv import AddTwoInts


class AddTwoIntsServer(Node):
    def __init__(self):
        super().__init__("add_two_ints_server")
        # 创建一个服务器
        # 服务名称add_two_ints，建议对服务名称使用动词
        self.server_ = self.create_service(
            AddTwoInts, "add_two_ints", self.callback_add_two_ints
        )
        self.get_logger().info("Add Two Ints server has been started.")

    # 正好说明AddTwoInts是两条消息的组合
    # 一条是AddTwoInts.Request，另一条是AddTwoInts.Response
    def callback_add_two_ints(
        self, request: AddTwoInts.Request, response: AddTwoInts.Response
    ):
        response.sum = request.a + request.b
        self.get_logger().info(
            str(request.a) + " + " + str(request.b) + " = " + str(response.sum)
        )
        # 返回响应
        return response


def main(args=None):
    rclpy.init(args=args)
    node = AddTwoIntsServer()
    rclpy.spin(node)
    rclpy.shutdown()


if __name__ == "__main__":
    main()

```

## setup.py

> 添加程序

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
            "number_publisher=my_py_pkg.number_publisher:main",
            "number_counter=my_py_pkg.number_counter:main",
            #添加该行
            "add_two_ints_server=my_py_pkg.add_two_ints_server:main"
        ],
    },
```

## build,source,run

```bash
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ colcon build --packages-select my_py_pkg --symlink-install
Starting >>> my_py_pkg
Finished <<< my_py_pkg [15.8s]

Summary: 1 package finished [16.6s]


```

```bash
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 run my_py_pkg add_two_ints_server
[INFO] [1791365392.263256848] [add_two_ints_server]: Add Two Ints server has been started.

#查看
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 node list

╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 node list
/add_two_ints_server

╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 node info /add_two_ints_server
/add_two_ints_server
  Subscribers:

  Publishers:
    /parameter_events: rcl_interfaces/msg/ParameterEvent
    /rosout: rcl_interfaces/msg/Log
  Service Servers:
    /add_two_ints: example_interfaces/srv/AddTwoInts #这个是我们创建的那个
    #接下来的七个，它们是 ROS 2 Node 自己提供的参数相关服务。
    /add_two_ints_server/describe_parameters: rcl_interfaces/srv/DescribeParameters
    /add_two_ints_server/get_parameter_types: rcl_interfaces/srv/GetParameterTypes
    #其他节点可以通过这个 Service 查询 /add_two_ints_server 的参数。 
    /add_two_ints_server/get_parameters: rcl_interfaces/srv/GetParameters
    /add_two_ints_server/get_type_description: type_description_interfaces/srv/GetTypeDescription
    /add_two_ints_server/list_parameters: rcl_interfaces/srv/ListParameters
    /add_two_ints_server/set_parameters: rcl_interfaces/srv/SetParameters
    /add_two_ints_server/set_parameters_atomically: rcl_interfaces/srv/SetParametersAtomically
  Service Clients:

  Action Servers:

  Action Clients:

```

### 参数指的是？

`/add_two_ints_server/get_parameters`

这里的“参数”指的是 **ROS 2 Node 的 Parameter（参数）**，不是函数参数，也不是 Service 的 `a、b`。

可以先把它理解成：

> **运行中的 Node 身上保存的一些可配置的键值对。**

例如一个机器人节点可能有：

```text
速度上限 = 1.5
机器人名字 = "robot1"
是否启用激光雷达 = true
```

这些就是这个 Node 的 Parameters。

> 例如

假设有一个节点：

```text
/camera
```

启动时给它设置：

```bash
ros2 run xxx camera_node --ros-args -p exposure:=100
```

那么这个节点就有一个参数：

```text
exposure = 100
```

其他节点可以通过：

```text
/camera/get_parameters
```

查询：

> `/camera` 当前 `exposure` 是多少？

也可以通过：

```text
/camera/set_parameters
```

修改它。

### 直接在命令行使用客户端

```bash
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 service call /add_two_ints example_interfaces/srv/AddTwoInts "{a: 3,b: 7}"
waiting for service to become available...
requester: making request: example_interfaces.srv.AddTwoInts_Request(a=3, b=7)

response:
example_interfaces.srv.AddTwoInts_Response(sum=10)
```

