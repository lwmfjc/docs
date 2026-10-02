---
title: "0305-"
description: "0305-"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-02T14:09:23+08:00
lastmod: 2026-10-02T14:09:23+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 什么是ROS2节点

> 节点是应用程序的一个子部分，可以使用Python或C++语言对其进行编码

> 一个节点应该只有一个单一的目的，应用程序将包含很多节点，这些***节点将放入包***中，***节点之间将相互通信***

> 示例 ~~每个节点可以单独启动~~ 
> 有时很难判断是否将两个节点放入同一个包中：图像处理节点那可以是另一个包的一部分（因为可以让它只处理***任何***摄像头的图像） ~~这里还假设摄像头驱动程序和图像处理拥有同样依赖项（所以放同一个包中）~~ 

![](img/ly-20261002171037536.png)  
1. 运动规划包（Motion planning pkg）
   - Path correction（路径校正节点）： 接收视觉分析发来的环境信息，进行路径校正，并向运动规划节点发送通知。   
   - Motion planning（运动规划节点）： 结合校正后的路径与硬件状态数据，计算出机器人的运动轨迹。   
2. 摄像头包（Camera pkg）
   - Camera driver（驱动程序节点）： 负责获取摄像头的原始图像帧，并将其传递给图像处理节点。   
   - Image processing（图像处理节点）： 对摄像头图像进行处理分析，并将环境分析结果发送给路径校正节点（Path correction）。   
3. 硬件控制包（Hardware control pkg）
   作为一个独立单元控制机器人的底层硬件（如带有控制循环的电机驱动程序）：   
   - State publisher（状态发布节点）： 将来自电机编码器等硬件的位置/状态信息发布出去；运动规划节点和路径校正节点都会接收这些硬件状态消息。   
   - Hardware driver（硬件驱动节点）： 接收来自运动规划节点（Motion planning）计算好的轨迹指令，驱动底盘或电机运行；同时将其运行数据传给状态发布节点。   

数据流与通信关系

- 摄像头 ➔ 路径校正： 图像处理节点分析环境后，将分析结果发送给 Path correction 节点。   
- 路径校正 ➔ 运动规划： Path correction 节点向 Motion planning 节点发送通知。   
- 硬件状态反馈： State publisher 节点发布硬件状态后，Motion planning 和 Path correction 节点都在接收这些状态消息。   
- 控制指令下发： Motion planning 节点将计算出的轨迹直接发送给 Hardware driver 执行。   

> 节点是应用程序的一个子程序，负责一件事，就像在使用面向对象编程编写类一样，您知道该类只服务于单一目的

> 节点组合成一个图，并使用话题、服务、参数等相互通信。 ~~接下来的部分将介绍通信工具~~ 

> 节点的优点

- 降低代码复杂度（是程序容易扩展）
- 极好的容错能力，如果在不同进程中运行节点，那么他们不是直接连接的，可以借助ROS2通信继续通信 ~~如果一个节点崩溃不会导致其他节点（功能）崩溃~~ 
- 与语言无关 ~~可以使用Python、CPP且他们之间可以通信~~ 
    - 可以使用Python开发大部分应用程序，而某些节点 ~~需要快速执行速度的~~ 用CPP编写

> 两个节点不能有相同名称，如果想运行同一个节点多个实例，那么必须修改它们的名称或者放入不同的命名空间，例如

```bash
ros2 run demo_nodes_cpp talker 
```

里面：

- demo_nodes_cpp = ***ROS 2 软件包（package）名称***
- talker = ***可执行程序（executable）名称***
    - 默认情况下：***可执行程序名 = 节点名***

```bash
#程序启动后，把节点名字改成 talker1
ros2 run demo_nodes_cpp talker --ros-args --name talker1
#或者把它放入另一个命名空间
ros2 run demo_nodes_cpp talker --ros-args -r __ns:=/robot1
```

默认命名空间是：`/` ，也就是根命名空间（root namespace）。

所以：`ros2 run demo_nodes_cpp talker`

实际上创建的是：

```bash
节点名: /talker
命名空间: /
```

> 接下来将看到如何实际在Python和C++中创建节点，使用命令行工具使用它们，然后如何让它们通信

# 编写一个Python节点(最小代码)

```bash
#先切换到Python包所在的目录
╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg
╰─❯ ls
my_py_pkg  package.xml  resource  setup.cfg  setup.py  test

#进入与包同名的文件夹
╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg
╰─❯ cd my_py_pkg

╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg
╰─❯ ls
__init__.py

╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg
╰─❯ touch my_first_node.py

```

在VSCode中打开 `ros2_ws/src` 文件夹  

```python
#!/usr/bin/env python3

#请系统调用 /usr/bin/env，让它在当前环境的 PATH 中（按照目录顺序）找到 python3（这个可执行程序），然后用这个 Python3 来执行本文件。
#记得现在VSCode安装ROS拓展
import rclpy 
from rclpy.node import Node

def main(args=None):
    #将初始化ROS2通信以及需要的所有内容，以便创建和使用节点
    rclpy.init(args=args)
    #创建一个节点，给它一个名称：py_test
    node=Node("py_test")
    #在终端打印内容
    node.get_logger().info("Hello world");
    #关闭
    rclpy.shutdown()

#如果直接从终端运行程序则执行main
if __name__ == "__main__":
    main()

```

> 执行

```bash
╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg
╰─❯ ls
__init__.py  my_first_node.py

╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg
╰─❯ chmod +x my_first_node.py

╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg
╰─❯ ./my_first_node.py
[INFO] [1790938553.858442914] [py_test]: Hello world
```

> 修改程序并在`rclpy.shutdown()`之前添加`rclpy.spin(node)`

```python
#!/usr/bin/env python3

#请系统调用 /usr/bin/env，让它在当前环境的 PATH 中（按照目录顺序）找到 python3（这个可执行程序），然后用这个 Python3 来执行本文件。
#记得现在VSCode安装ROS拓展
import rclpy 
from rclpy.node import Node

def main(args=None):
    #将初始化ROS2通信以及需要的所有内容，以便创建和使用节点
    rclpy.init(args=args)
    #创建一个节点，给它一个名称：py_test
    node=Node("py_test")
    #在终端打印内容
    node.get_logger().info("Hello world");
    #spin将使节点保持存活，知道按下Ctrl+C
    rclpy.spin(node)
    #关闭
    rclpy.shutdown()

#如果直接从终端运行程序则执行main
if __name__ == "__main__":
    main()
    
```

## 直接执行节点.py文件

```bash
╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg
╰─❯ ./my_first_node.py
[INFO] [1790938735.830189034] [py_test]: Hello world
^CTraceback (most recent call last): #这里我按了ctrl+c，报错是正常的
  File "/home/ly/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg/./my_first_node.py", line 22, in <module>
    main()
  File "/home/ly/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg/./my_first_node.py", line 16, in main
    rclpy.spin(node)
  File "/opt/ros/jazzy/lib/python3.12/site-packages/rclpy/__init__.py", line 247, in spin
    executor.spin_once()
  File "/opt/ros/jazzy/lib/python3.12/site-packages/rclpy/executors.py", line 926, in spin_once
    self._spin_once_impl(timeout_sec)
  File "/opt/ros/jazzy/lib/python3.12/site-packages/rclpy/executors.py", line 907, in _spin_once_impl
    handler, entity, node = self.wait_for_ready_callbacks(
                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/opt/ros/jazzy/lib/python3.12/site-packages/rclpy/executors.py", line 877, in wait_for_ready_callbacks
    return next(self._cb_iter)
           ^^^^^^^^^^^^^^^^^^^
  File "/opt/ros/jazzy/lib/python3.12/site-packages/rclpy/executors.py", line 781, in _wait_for_ready_callbacks
    wait_set.wait(timeout_nsec)
KeyboardInterrupt
```

> 刚刚是直接执行文件，但是我们需要的是**安装它并创建一个可执行文件**，然后可以用ROS2命令行启动它

## 安装节点

> 修改my_py_pkg/setup.py

```python
from setuptools import find_packages, setup

package_name = 'my_py_pkg'

setup(
    #省略了
    #只修改下面这个块
    entry_points={
        'console_scripts': [
            #文件夹my_py_pkg下的my_first_node.py文件
            #main是.py文件中的函数
            #py_node 是可执行文件的名称
            "py_node = my_py_pkg.my_first_node:main",
            #可以再添加其他的可执行文件，和上面同样的格式即可
        ],
    },
)

```

> 切换回工作空间进行操作

```bash
╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg                    
╰─❯ cd ~/HelloROS2/ros2_ws

#构建Python的那个包
╭─ ~/HelloROS2/ros2_ws
╰─❯ colcon build --packages-select my_py_pkg
Starting >>> my_py_pkg
Finished <<< my_py_pkg [4.99s]

Summary: 1 package finished [6.04s]
```

> 由于在工作空间中创建了新东西，所以需要source工作空间

```bash
source install/setup.sh
#或者(如果是ohmyzsh终端)
source install/setup.zsh
#或者（因为最后有两行 source /opt/ros/jazzy/setup.bash 和 source ~/HelloROS2/ros2_ws/install/setup.bash
source ~/.bashrc
#或者(如果是ohmyzsh终端)
source ~/.zshrc
```

> 这里我切换到了用户根目录，然后仅仅source 工作空间下的install的setup.zsh

## 启动节点

```bash
╭─ ~
╰─❯ ls -l  HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg/my_first_node.py
-rwxr-xr-x 1 ly ly 761 Oct  2 18:57 HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg/my_first_node.py

#这里去不去除都没事，我只是验证他没有可执行权限也可以通过ros2命令运行
╭─ ~
╰─❯ chmod -x  HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg/my_first_node.py

╭─ ~
╰─❯ ls -l  HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg/my_first_node.py
-rw-r--r-- 1 ly ly 761 Oct  2 18:57 HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg/my_first_node.py

#其中 my_py_pkg py_node 都支持自动补全
#可执行文件名py_node是 setup.py中创建的 "py_node = my_py_pkg.my_first_node:main"，是安装节点之后才有的东西
#my_first_node.py中的node=Node("py_test")中的"py_test"是节点名称
#my_py_pkg 是包名
╭─ ~
╰─❯ ros2 run  my_py_pkg py_node
[INFO] [1790939723.045164980] [py_test]: Hello world

```

> 1. 可执行文件名py_node是 `setup.py`中创建的 `"py_node = my_py_pkg.my_first_node:main"`，是安装节点之后才有的东西
> 2. `my_first_node.py`中的`node=Node("py_test")`中的"py_test"是节点名称
> 3. 可执行文件名，和节点名称，是不同的东西
> 4. `my_first_node.py` 是文件名

> 我们有在`my_first_node.py`文件内部创建的节点名称，有创建的可执行文件名 `setup.py`中创建的 `"py_node = my_py_pkg.my_first_node:main"`。以便我们可以与ROS2一起使用