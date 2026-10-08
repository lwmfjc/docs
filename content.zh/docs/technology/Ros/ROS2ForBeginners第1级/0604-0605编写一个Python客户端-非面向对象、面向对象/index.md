---
title: "0604-0605编写一个Python客户端-非面向对象、面向对象"
description: "0604-0605编写一个Python客户端-非面向对象、面向对象"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-07T17:42:19+08:00
lastmod: 2026-10-07T17:42:19+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 编写一个Python客户端-非面向对象

> 创建一个Python service client，从代码中调用服务

> 本课，将了解创建service client，send request，get the response

> 终端调用服务仅适用于非常简单的请求

```bash
╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg main
╰─❯ touch add_two_ints_client_no_oop.py
```

> 编写代码 `add_two_ints_client_no_oop.py`

```python
#!/usr/bin/env python3
import rclpy
from rclpy.node import Node
from example_interfaces.srv import AddTwoInts


def main(args=None):
    rclpy.init(args=args)
    node = Node("add_two_ints_client_no_oop")
    #在节点内创建一个客户端
    client = node.create_client(AddTwoInts, "add_two_ints")
    # 为了确保创建客户端并找到服务器
    # 1秒的超时时间
    while not client.wait_for_service(1.0):
        node.get_logger().warn("Waiting for Add Two Ints server...")

    rclpy.shutdown()


if __name__ == "__main__":
    main()

```

> setup.py中创建新的可执行文件

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
            "add_two_ints_server=my_py_pkg.add_two_ints_server:main",
            #添加该行
            "add_two_ints_client_no_oop=my_py_pkg.add_two_ints_client_no_oop:main"
        ],
    },
```

```bash
#build,source,run
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ colcon build --packages-select my_py_pkg --symlink-install
Starting >>> my_py_pkg
Finished <<< my_py_pkg [18.3s]

Summary: 1 package finished [18.8s]

╭─ ~/HelloROS2/ros2_ws main !1 ?1                                                21s
╰─❯ source install/setup.zsh

╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 run my_py_pkg add_two_ints_client_no_oop
[WARN] [1791425847.830996572] [add_two_ints_client_no_oop]: Waiting for Add Two Ints server...
[WARN] [1791425848.834953537] [add_two_ints_client_no_oop]: Waiting for Add Two Ints server...
[WARN] [1791425849.839600597] [add_two_ints_client_no_oop]: Waiting for Add Two Ints server...
[WARN] [1791425850.842064211] [add_two_ints_client_no_oop]: Waiting for Add Two Ints server...
[WARN] [1791425851.845766336] [add_two_ints_client_no_oop]: Waiting for Add Two Ints server...
[WARN] [1791425852.849523587] [add_two_ints_client_no_oop]: Waiting for Add Two Ints server...
[WARN] [1791425853.853364099] [add_two_ints_client_no_oop]: Waiting for Add Two Ints server...
[WARN] [1791425854.857941196] [add_two_ints_client_no_oop]: Waiting for Add Two Ints server...
[WARN] [1791425855.86167778
```

```bash
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 run my_py_pkg add_two_ints_server
[WARN] [1791425904.189785849] [add_two_ints_server]: Add Two Ints server has been started.

#启动上面那个服务后，客户端没有等待，继续执行后续代码然后退出了
#╭─ ~/HelloROS2/ros2_ws main !1 ?1
#╰─❯ ros2 run my_py_pkg add_two_ints_client_no_oop
[WARN] [1791425847.830996572] [add_two_ints_client_no_oop]: Waiting for Add Two Ints server...
[WARN] [1791425848.834953537] [add_two_ints_client_no_oop]: Waiting for Add Two Ints server...
#省略了
#......
[WARN] [1791425904.095443951] [add_two_ints_client_no_oop]: Waiting for Add Two Ints server...

╭─ ~/HelloROS2/ros2_ws main !1 ?1   
╰─❯
```

> 完整功能客户端

> 以下可以当做模板来测试任何你想测试的服务器

```python
#!/usr/bin/env python3
import rclpy
from rclpy.node import Node
from example_interfaces.srv import AddTwoInts


def main(args=None):
    rclpy.init(args=args)
    node = Node("add_two_ints_client_no_oop")
    # 在节点内创建一个客户端
    client = node.create_client(AddTwoInts, "add_two_ints")
    # 为了确保创建客户端并找到服务器
    # 1秒的超时时间
    while not client.wait_for_service(1.0):
        node.get_logger().warn("Waiting for Add Two Ints server...")

    request = AddTwoInts.Request()
    request.a = 3
    request.b = 8
    # call会阻塞执行，而实际上要获取响应，需要节点处于自旋
    # client.call

    future = client.call_async(request)

    # 让节点自旋直到future完成
    rclpy.spin_until_future_complete(node, future)

    response = future.result()
    node.get_logger().info(
        str(request.a) + " + " + str(request.b) + " = " + str(response.sum)
    )
    rclpy.shutdown()


if __name__ == "__main__":
    main()

```

### ROS 2 Service 接口与 Python 类型

- `.srv` = ROS 2 的 Service 接口定义
- `AddTwoInts.srv` = 定义 Service 的 Request 和 Response 数据结构

例如：

```
    int64 a
    int64 b
    ---
    int64 sum
```

根据 `.srv` 接口定义，ROS 2 会生成对应的语言类型。
在 Python 中表现为 `AddTwoInts` 类型/类。

可以理解为：

```
AddTwoInts
├── Request   ← Request 类型
└── Response  ← Response 类型
```


- `AddTwoInts` = 根据 `.srv` 接口生成的 Python 类型/类
- `AddTwoInts.Request` = Request 类型
- `AddTwoInts.Response` = Response 类型

因此：

- `AddTwoInts.Request()` = 创建一个具体的 Request 对象
- `AddTwoInts.Response()` = 创建一个具体的 Response 对象

例如：

```
request = AddTwoInts.Request()
request.a = 3
request.b = 8
```

这里：

```
`AddTwoInts.Request` 是一个类型
`AddTwoInts.Request()` 是实例化这个类型
`request` 是创建出来的具体 Request 对象
```


### 与普通消息的区别

- `String` → 一个消息类型
- `String()` → 创建一个具体的消息对象

而 Service 有 Request / Response 两种数据结构：

- `AddTwoInts` → 一个 Service 类型
- `AddTwoInts.Request` → Request 类型
- `AddTwoInts.Request()` → 创建具体的 Request 对象
- `AddTwoInts.Response` → Response 类型
- `AddTwoInts.Response()` → 创建具体的 Response 对象

## 运行

```bash
#先启动客户端
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 run my_py_pkg add_two_ints_client_no_oop
[WARN] [1791427764.630959959] [add_two_ints_client_no_oop]: Waiting1 for Add Two Ints server...
[WARN] [1791427765.638214143] [add_two_ints_client_no_oop]: Waiting1 for Add Two Ints server...
[WARN] [1791427766.647006960] [add_two_ints_client_no_oop]: Waiting1 for Add Two Ints server...
[WARN] [1791427767.656778174] [add_two_ints_client_no_oop]: Waiting1 for Add Two Ints server...
[WARN] [1791427768.663187135] [add_two_ints_client_no_oop]: Waiting1 for Add Two Ints server...
[WARN] [1791427769.666412313] [add_two_ints_client_no_oop]: Waiting1 for Add Two Ints server...
[WARN] [1791427770.669663871] [add_two_ints_client_no_oop]: Waiting1 for Add Two Ints server...
[WARN] [1791427771.672734293] [add_two_ints_client_no_oop]: Waiting1 for Add Two Ints server...

#启动服务端
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 run my_py_pkg add_two_ints_server
[INFO] [1791427772.050073740] [add_two_ints_server]: Add Two Ints server has been started.
[INFO] [1791427773.303207791] [add_two_ints_server]: 3 + 8 = 11

#查看客户端
#╭─ ~/HelloROS2/ros2_ws main !1 ?1
#╰─❯ ros2 run my_py_pkg add_two_ints_client_no_oop
[WARN] [1791427764.630959959] [add_two_ints_client_no_oop]: Waiting1 for Add Two Ints server...
[WARN] [1791427765.638214143] [add_two_ints_client_no_oop]: Waiting1 for Add Two Ints server...
[WARN] [1791427766.647006960] [add_two_ints_client_no_oop]: Waiting1 for Add Two Ints server...
[WARN] [1791427767.656778174] [add_two_ints_client_no_oop]: Waiting1 for Add Two Ints server...
[WARN] [1791427768.663187135] [add_two_ints_client_no_oop]: Waiting1 for Add Two Ints server...
[WARN] [1791427769.666412313] [add_two_ints_client_no_oop]: Waiting1 for Add Two Ints server...
[WARN] [1791427770.669663871] [add_two_ints_client_no_oop]: Waiting1 for Add Two Ints server...
[WARN] [1791427771.672734293] [add_two_ints_client_no_oop]: Waiting1 for Add Two Ints server...
[INFO] [1791427773.333543567] [add_two_ints_client_no_oop]: 3 + 8 = 11
```

# 编写一个Python客户端-面向对象

```bash
╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg main !1 ?1
╰─❯ touch add_two_ints_client.py
```

## 代码

```python
#!/usr/bin/env python3
import rclpy
from rclpy.node import Node
from example_interfaces.srv import AddTwoInts


class AddTwoIntClient(Node):
    def __init__(self):
        super().__init__("add_two_int_client")
        # 创建一个客户端，它连接的是 AddTwoInts 类型的 Service。
        self.client_ = self.create_client(AddTwoInts, "add_two_ints")

    def call_add_two_ints(self, a, b):
        while not self.client_.wait_for_service(1.0):
            self.get_logger().warn("Waiting for Add Two Ints server...")
        # 按照这个 Service 的 Request 定义，创建一个具体的请求。
        request = AddTwoInts.Request()
        request.a = a
        request.b = b

        # 异步调用(这里不会阻塞)
        # 因为节点已经正在自旋，所以不会结束程序
        # 1. 把 request 发给 Service Server
        # 2. 立即返回一个 Future，而不是等待 Response
        future = self.client_.call_async(request)
        # 为收到响应时收到回调(这里只是注册回调，也不会阻塞)
        future.add_done_callback(self.callback_call_add_two_ints)

    def callback_call_add_two_ints(self, future):
        response = future.result()
        self.get_logger().info("Got response: " + str(response.sum))


def main(args=None):
    rclpy.init(args=args)
    node = AddTwoIntClient()
    node.call_add_two_ints(2,7)
    # 让节点进入自选状态
    # 让 ROS 2 持续运行并处理这个节点的事件
    rclpy.spin(node)
    rclpy.shutdown()


if __name__ == "__main__":
    main()

```

## 添加可执行文件
```python
entry_points={
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
            #添加这行
            "add_two_ints_client=my_py_pkg.add_two_ints_client:main",
        ],
    },
```

## 编译运行

```bash
#构建并安装
╭─ ~/HelloROS2/ros2_ws main !2
╰─❯ colcon build --packages-select my_py_pkg --symlink-install
Starting >>> my_py_pkg
Finished <<< my_py_pkg [5.65s]

Summary: 1 package finished [6.05s]

#加载构建后的环境
╭─ ~/HelloROS2/ros2_ws main !2   
╰─❯ source install/setup.zsh

#运行
#先启动客户端
╭─ ~/HelloROS2/ros2_ws main !2      
╰─❯ ros2 run my_py_pkg add_two_ints_client
[WARN] [1791431206.862956500] [add_two_int_client]: Waiting for Add Two Ints server...
[INFO] [1791431207.370823398] [add_two_int_client]: Got response: 9

#启动服务器接收请求
╭─ ~/HelloROS2/ros2_ws main !2    
╰─❯ ros2 run my_py_pkg add_two_ints_server
[INFO] [1791431203.074816411] [add_two_ints_server]: Add Two Ints server has been started.
[INFO] [1791431207.367484444] [add_two_ints_server]: 2 + 7 = 9
```

> 在回调函数中接收request

```python
#!/usr/bin/env python3
import rclpy
from rclpy.node import Node
from example_interfaces.srv import AddTwoInts
#添加这行1
from functools import partial


class AddTwoIntClient(Node):
    def __init__(self):
        super().__init__("add_two_int_client")
        # 创建一个客户端，它连接的是 AddTwoInts 类型的 Service。
        self.client_ = self.create_client(AddTwoInts, "add_two_ints")

    def call_add_two_ints(self, a, b):
        while not self.client_.wait_for_service(1.0):
            self.get_logger().warn("Waiting for Add Two Ints server...")
        # 按照这个 Service 的 Request 定义，创建一个具体的请求。
        request = AddTwoInts.Request()
        request.a = a
        request.b = b

        # 异步调用(这里不会阻塞)
        # 因为节点已经正在自旋，所以不会结束程序
        # 1. 把 request 发给 Service Server
        # 2. 立即返回一个 Future，而不是等待 Response
        future = self.client_.call_async(request)
        # 为收到响应时收到回调(这里只是注册回调，也不会阻塞)
        # 如果想为future对象的add_done_callback添加额外参数，需要添加functools里面的partial函数
        
        #修改这行2
        future.add_done_callback(
            partial(self.callback_call_add_two_ints, request=request)
        )

    #修改这行2
    # request参数：在回调中直到请求
    def callback_call_add_two_ints(self, future, request):
        response = future.result()
        self.get_logger().info("Got response: " + str(response.sum))
        self.get_logger().info(
            str(request.a) + " + " + str(request.b) + " = " + str(response.sum)
        )


def main(args=None):
    rclpy.init(args=args)
    node = AddTwoIntClient()
    node.call_add_two_ints(2, 7)
    # 让节点进入自选状态
    # 让 ROS 2 持续运行并处理这个节点的事件
    rclpy.spin(node)
    rclpy.shutdown()


if __name__ == "__main__":
    main()

```

```bash
#重新运行client
╭─ ~/HelloROS2/ros2_ws main !2      
╰─❯ ros2 run my_py_pkg add_two_ints_client
[INFO] [1791432227.139235330] [add_two_int_client]: Got response: 9
[INFO] [1791432227.140197843] [add_two_int_client]: 2 + 7 = 9

#查看服务器
#╭─ ~/HelloROS2/ros2_ws main !2   
#╰─❯ ros2 run my_py_pkg add_two_ints_server
[INFO] [1791431203.074816411] [add_two_ints_server]: Add Two Ints server has been started.
[INFO] [1791431207.367484444] [add_two_ints_server]: 2 + 7 = 9
#下面这个是新接收到的请求
[INFO] [1791432227.103927972] [add_two_ints_server]: 2 + 7 = 9
```

> 修改 add_two_ints_client.py 的main函数

```python
def main(args=None):
    rclpy.init(args=args)
    node = AddTwoIntClient()
    node.call_add_two_ints(2, 7)
    #新增下面两个请求
    node.call_add_two_ints(1, 4)
    node.call_add_two_ints(10, 20)
    # 让节点进入自选状态
    # 让 ROS 2 持续运行并处理这个节点的事件
    rclpy.spin(node)
    rclpy.shutdown()

```

```bash
#重新运行client
╭─ ~/HelloROS2/ros2_ws main !2     
╰─❯ ros2 run my_py_pkg add_two_ints_client
[INFO] [1791432394.827565813] [add_two_int_client]: Got response: 9
[INFO] [1791432394.829550141] [add_two_int_client]: 2 + 7 = 9
[INFO] [1791432394.832276076] [add_two_int_client]: Got response: 5
[INFO] [1791432394.834382534] [add_two_int_client]: 1 + 4 = 5
[INFO] [1791432394.840665381] [add_two_int_client]: Got response: 30
[INFO] [1791432394.841518384] [add_two_int_client]: 10 + 20 = 30

#查看server
╭─ ~/HelloROS2/ros2_ws main !2     
╰─❯ ros2 run my_py_pkg add_two_ints_server
[INFO] [1791431203.074816411] [add_two_ints_server]: Add Two Ints server has been started.
[INFO] [1791431207.367484444] [add_two_ints_server]: 2 + 7 = 9
[INFO] [1791432227.103927972] [add_two_ints_server]: 2 + 7 = 9
#新增的三条请求
[INFO] [1791432394.766834721] [add_two_ints_server]: 2 + 7 = 9
[INFO] [1791432394.772444194] [add_two_ints_server]: 1 + 4 = 5
[INFO] [1791432394.778245198] [add_two_ints_server]: 10 + 20 = 30

```