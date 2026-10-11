---
title: "0710活动四解决方案02创建服务"
description: "0710活动四解决方案02创建服务"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-11T08:36:06+08:00
lastmod: 2026-10-11T08:36:06+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
***添加service server***

> 允许我们从节点外部修改led的状态

# 创建一个服务接口

```bash
╭─ ~/HelloROS2/ros2_ws main !2 ?2
╰─❯ cd src/my_robot_interfaces/srv

╭─ ~/HelloROS2/ros2_ws/src/my_robot_interfaces/srv main !2 ?2
╰─❯ ls
ComputeRectangleArea.srv

╭─ ~/HelloROS2/ros2_ws/src/my_robot_interfaces/srv main !2 ?2
╰─❯ touch SetLed.srv
```

> 编辑SetLed.srv

```bash
int64 led_number
int64 state
---
bool success
```

> CMakeLists.txt中添加服务接口

```cmake
# 用来生成接口的命令，我们要在里面写上所有创建的接口的路径
rosidl_generate_interfaces(
	${PROJECT_NAME}
	"msg/HardwareStatus.msg" 
	"srv/ComputeRectangleArea.srv" 
	"msg/LedStatusArray.msg"
	"srv/SetLed.srv" 
)
```

> build,source,run

```bash
#编译并构建功能包
╭─ ~/HelloROS2/ros2_ws main !2 ?3
╰─❯ colcon build --packages-select my_robot_interfaces
[1.265s] WARNING:colcon.colcon_core.package_selection:Some selected packages are already built in one or more underlay workspaces:
        'my_robot_interfaces' is in: /home/ly/HelloROS2/ros2_ws/install/my_robot_interfaces
If a package in a merged underlay workspace is overridden and it installs headers, then all packages in the overlay must sort their include directories by workspace order. Failure to do so may result in build failures or undefined behavior at run time.
If the overridden package is used by another package in any underlay, then the overriding package in the overlay must be API and ABI compatible or undefined behavior at run time may occur.

If you understand the risks and want to override a package anyways, add the following to the command line:
        --allow-overriding my_robot_interfaces

This may be promoted to an error in a future release of colcon-override-check.
Starting >>> my_robot_interfaces
Finished <<< my_robot_interfaces [29.2s]

Summary: 1 package finished [29.6s]

#加载构建后的环境
╭─ ~/HelloROS2/ros2_ws main !2 ?3   
╰─❯ source install/setup.zsh

#查看某个包中定义的接口
╭─ ~/HelloROS2/ros2_ws main !2 ?3
╰─❯ ros2 interface package my_robot_interfaces
my_robot_interfaces/msg/LedStatusArray
my_robot_interfaces/srv/SetLed
my_robot_interfaces/msg/HardwareStatus
my_robot_interfaces/srv/ComputeRectangleArea

╭─ ~/HelloROS2/ros2_ws main !2 ?3
╰─❯ ros2 interface show my_robot_interfaces/srv/SetLed
int64 led_number
int64 state
---
bool success
```

# 编写服务

> 重启vscode

> 确保已经在package.xml中添加依赖my_robot_interfaces

> let_panel.py

```python
#!/usr/bin/env python3
import rclpy
from rclpy.node import Node

# 如果没有自动补全，source后启一下vscode
from my_robot_interfaces.msg import LedStatusArray
#1 添加这个
from my_robot_interfaces.srv import SetLed


# 需要一个发布器、一个定时器、服务
class LEDPanelNode(Node):
    def __init__(self):
        super().__init__("led_panel")
        self.led_states_ = [0, 0, 0]
        #发布者
        self.led_states_pub_ = self.create_publisher(
            LedStatusArray, "led_panel_state", 10
        )
        #定时器
        self.led_states_timer_ = self.create_timer(5.0, self.publish_led_states)
        #2 添加这个
        #服务
        self.set_led_service_ = self.create_service(
            SetLed, "set_led", self.callback_set_led
        )
        self.get_logger().info("LED panel node has been started.")

    def publish_led_states(self):
        msg = LedStatusArray()
        msg.led_status = self.led_states_
        self.led_states_pub_.publish(msg)

    #3 添加这个
    def callback_set_led(self, request: SetLed.Request, response: SetLed.Response):
        # 验证数据
        led_number = request.led_number
        state = request.state

        if led_number >= len(self.led_states_) or led_number < 0:
            response.success = False
            return response
        if state not in [0, 1]:
            response.success = False
            return response
        # 执行动作
        self.led_states_[led_number] = state
        response.success = True
        return response


def main(args=None):
    rclpy.init(args=args)
    node = LEDPanelNode()
    rclpy.spin(node)
    rclpy.shutdown()


if __name__ == "__main__":
    main()

```

> 由于前面构建时使用了 `--symlink-install`，直接run即可

```bash
╭─ ~/HelloROS2/ros2_ws main !2 ?3
╰─❯ ros2 run my_py_pkg led_panel
[INFO] [1791680721.784909522] [led_panel]: LED panel node has been started.

#查询
╭─ ~/HelloROS2/ros2_ws main !2 ?3
╰─❯ ros2 node list
/led_panel

╭─ ~/HelloROS2/ros2_ws main !2 ?3
╰─❯ ros2 service list
/led_panel/describe_parameters
/led_panel/get_parameter_types
/led_panel/get_parameters
/led_panel/get_type_description
/led_panel/list_parameters
/led_panel/set_parameters
/led_panel/set_parameters_atomically
/set_led
```

```bash
#命令行订阅话题
╭─ ~/HelloROS2/ros2_ws main !2 ?3
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
  
#命令行请求服务
╭─ ~/HelloROS2/ros2_ws main !2 ?3
╰─❯ ros2 service call /set_led my_robot_interfaces/srv/SetLed "{led_number: 0,state: 1}"
requester: making request: my_robot_interfaces.srv.SetLed_Request(led_number=0, state=1)

response:
my_robot_interfaces.srv.SetLed_Response(success=True)

#查看刚才的话题订阅者
#╭─ ~/HelloROS2/ros2_ws main !2 ?3
#╰─❯ ros2 topic echo /led_panel_state
led_status:
- 0
- 0
- 0
---
led_status:
- 0
- 0
- 0
---
led_status:
- 1
- 0
- 0
---
led_status:
- 1
- 0
- 0
---
led_status:
- 1
- 0
- 0
---
```

> 修改led_panel.py，每当状态改变时让她立即发布新状态   ~~添加self.publish_led_states()~~ 

```python
    def callback_set_led(self, request: SetLed.Request, response: SetLed.Response):
        # 验证数据
        led_number = request.led_number
        state = request.state

        if led_number >= len(self.led_states_) or led_number < 0:
            response.success = False
            return response
        if state not in [0, 1]:
            response.success = False
            return response
        # 执行动作
        self.led_states_[led_number] = state
        #收到请求后立即发布话题(仅添加这行)
        self.publish_led_states()
        response.success = True
        return response

```

> 测试

```bash
╭─ ~/HelloROS2/ros2_ws main !2 ?3
╰─❯ ros2 run my_py_pkg led_panel         [INFO] [1791681141.988146186] [led_panel]: LED panel node has been started.

╭─ ~/HelloROS2/ros2_ws main !2 ?3
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
---
led_status:
- 0
- 0
- 0
  
#调用服务请求
╭─ ~/HelloROS2/ros2_ws main !2 ?3
╰─❯ ros2 service call /set_led my_robot_interfaces/srv/SetLed "{led_number: 0,state: 1}"
requester: making request: my_robot_interfaces.srv.SetLed_Request(led_number=0, state=1)

response:
my_robot_interfaces.srv.SetLed_Response(success=True)

#一旦发布请求就有新状态
#╭─ ~/HelloROS2/ros2_ws main !2 ?3
#╰─❯ ros2 topic echo /led_panel_state
led_status:
- 0
- 0
- 0
---
led_status:
- 0
- 0
- 0
---
led_status:
- 0
- 0
- 0
---
led_status:
- 1
- 0
- 0
---
led_status:
- 1
- 0
- 0
```

> 测试错误

```bash
╭─ ~/HelloROS2/ros2_ws main !2 ?3
╰─❯ ros2 service call /set_led my_robot_interfaces/srv/SetLed "{led_number: 4,state: 1}"
requester: making request: my_robot_interfaces.srv.SetLed_Request(led_number=4, state=1)

response:
my_robot_interfaces.srv.SetLed_Response(success=False)


╭─ ~/HelloROS2/ros2_ws main !2 ?3
╰─❯ ros2 service call /set_led my_robot_interfaces/srv/SetLed "{led_number: 4,state: 3}"
requester: making request: my_robot_interfaces.srv.SetLed_Request(led_number=4, state=3)

response:
my_robot_interfaces.srv.SetLed_Response(success=False)

```