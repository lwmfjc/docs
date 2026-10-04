---
title: "0503-"
description: "0503-"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-04T17:38:19+08:00
lastmod: 2026-10-04T17:38:19+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 编写一个Python发布者

> 创建一个节点，在节点中添加一个发布者，将以每秒两次的频率在某个主题发布一些文本

> 这里用之前的my_py_pkg中的包，在里面创建一个节点  

```bash
╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg main
╰─❯ ls
__init__.py  my_first_node_dian_py.bak  my_first_node.py  __pycache__

#在包的同名文件夹下，创建一个Python文件
#想象这是一个新闻站，将在一个主题上发布一些文本
╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg main
╰─❯ touch robot_news_station.py

#这是为了如果使用--symlink-install时，必须让文件拥有可执行权限
#我注释了是因为我发现没有可执行权限也是可以的
╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg main ?1
╰─❯ #chmod +x robot_news_station.py

╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg main ?1                         ✘ INT
╰─❯ cd ../..

#从src这个文件夹打开vscode
╭─ ~/HelloROS2/ros2_ws/src main ?1
╰─❯ code .

```

> 这里还有一个要点，就是视频作者这里创建了一个模版 ~~知识都是原来那些~~ ，文件名 `template_python_node.py`

```python
#!/usr/bin/env python3
import rclpy 
from rclpy.node import Node

class MyCustomNode(Node): #MODIFY NAME
    def __init__(self):
        super().__init__("py_test")  #MODIFY NAME
        
def main(args=None):
    rclpy.init(args=args) 
    node=MyCustomNode()  #MODIFY NAME
    rclpy.spin(node)
    rclpy.shutdown()

if __name__ == "__main__":
    main()

```

复制`template_python_node.py`内容并粘贴进`robot_news_station.py` 并修改。  

```bash
#用来显示且已安装的接口
╭─ ~/HelloROS2/ros2_ws main !1 ?2
╰─❯ ros2 interface show example_interfaces/msg/String
# This is an example message of using a primitive datatype, string.
# If you want to test with this that's fine, but if you are deploying
# it into a system you should create a semantically meaningful message type.
# If you want to embed it in another message, use the primitive data type instead.
string data #我们有一个data的字段，类型为string
```


