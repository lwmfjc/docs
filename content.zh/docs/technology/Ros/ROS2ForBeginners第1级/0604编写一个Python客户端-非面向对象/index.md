---
title: "0604编写一个Python客户端-非面向对象"
description: "0604编写一个Python客户端-非面向对象"
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