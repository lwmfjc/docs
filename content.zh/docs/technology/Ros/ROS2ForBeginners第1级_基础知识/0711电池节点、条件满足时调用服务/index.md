---
title: "0711电池节点、条件满足时调用服务"
description: "0711电池节点、条件满足时调用服务"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-11T09:23:43+08:00
lastmod: 2026-10-11T09:23:43+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
> 为电池创建一个新节点，模拟电池的行为，表示它是满电还是空电
> 满电或空电时将改变LED状态

```bash
╭─ ~/HelloROS2/ros2_ws main !2 ?3
╰─❯ cd src/my_py_pkg/my_py_pkg/

╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg main !2 ?3
╰─❯ ls
add_two_ints_client_no_oop.py  led_panel.py                number_publisher.py
add_two_ints_client.py         my_first_node_dian_py.bak   __pycache__
add_two_ints_server.py         my_first_node.py            robot_news_station.py
hardware_status_publisher.py   number_counter_dian_py_bak  smartphone.py
__init__.py                    number_counter.py           template_python_node.py

╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg main !2 ?3
╰─❯ touch battery.py

```

# 模拟电池的行为

> 4秒后电池耗尽，6秒后电池充满

> 编辑节点代码batter.py

```python
#!/usr/bin/env python3
import rclpy
from rclpy.node import Node


class BatteryNode(Node):
    def __init__(self):
        super().__init__("battery")
        self.batter_state_ = "full"
        self.last_time_battery_state_changed_ = self.get_current_time_seconds()
        # 创建一个定时器，每隔x时间检测一次电池状态(并修改电池状态，只是为了模拟)
        self.battery_timer_ = self.create_timer(0.1, self.check_battery_state)

    def get_current_time_seconds(self):
        # 会得到包含秒和纳秒的元组
        seconds, nanoseconds = self.get_clock().now().seconds_nanoseconds()
        return seconds + nanoseconds / 100000000.0

    def check_battery_state(self):
        time_now = self.get_current_time_seconds()
        # 如果距离上次已经大于某个时间则改变电池状态
        # 4.0秒后耗尽，6.0秒后充满
        if self.batter_state_ == "full":
            if time_now - self.last_time_battery_state_changed_ > 4.0:
                self.batter_state_ = "empty"
                self.get_logger().info("Battery is empty! Charging...")
                self.last_time_battery_state_changed_ = time_now
        elif self.batter_state_ == "empty":
            if time_now - self.last_time_battery_state_changed_ > 6.0:
                self.batter_state_ = "full"
                self.get_logger().info("Battery is  now full! ")
                self.last_time_battery_state_changed_ = time_now


def main(args=None):
    rclpy.init(args=args)
    node = BatteryNode()
    rclpy.spin(node)
    rclpy.shutdown()


if __name__ == "__main__":
    main()

```

> setup.py中添加可执行文件

```python
entry_points={
        "console_scripts": [
            # 省略原来的可执行文件（不是删除）
            # 只添加这行
            "battery=my_py_pkg.battery:main"
        ],
    },
```

> build,source,run

```bash
╭─ ~/HelloROS2/ros2_ws main !2 ?4
╰─❯ colcon build --packages-select my_py_pkg --symlink-install
Starting >>> my_py_pkg
Finished <<< my_py_pkg [7.93s]

Summary: 1 package finished [8.38s]

╭─ ~/HelloROS2/ros2_ws main !2 ?4         
╰─❯ source install/setup.zsh

#运行程序
╭─ ~/HelloROS2/ros2_ws main !2 ?4
╰─❯ ros2 run my_py_pkg battery
[INFO] [1791683170.968678802] [battery]: Battery is empty! Charging...
[INFO] [1791683177.939813973] [battery]: Battery is  now full!
[INFO] [1791683181.940893668] [battery]: Battery is empty! Charging...
[INFO] [1791683188.941728486] [battery]: Battery is  now full!
```

# 充满或耗尽时调用服务改变led

> 修改battery.py

```python
#!/usr/bin/env python3
import rclpy
from rclpy.node import Node
from my_robot_interfaces.srv import SetLed


class BatteryNode(Node):
    def __init__(self):
        super().__init__("battery")
        self.batter_state_ = "full"
        self.last_time_battery_state_changed_ = self.get_current_time_seconds()
        # 创建一个定时器，每隔x时间检测一次电池状态(并修改电池状态，只是为了模拟)
        self.battery_timer_ = self.create_timer(0.1, self.check_battery_state)
        self.set_led_client_ = self.create_client(SetLed, "set_led")
        self.get_logger().info("Battery node has been started.")

    def get_current_time_seconds(self):
        # 会得到包含秒和纳秒的元组
        seconds, nanoseconds = self.get_clock().now().seconds_nanoseconds()
        return seconds + nanoseconds / 100000000.0

    def check_battery_state(self):
        time_now = self.get_current_time_seconds()

        # 如果距离上次已经大于某个时间则改变电池状态
        # 4.0秒后耗尽，6.0秒后充满
        if self.batter_state_ == "full":
            if time_now - self.last_time_battery_state_changed_ > 4.0:
                self.batter_state_ = "empty"
                self.get_logger().info("Battery is empty! Charging...")
                # 电池空时亮起led
                self.call_set_led(2, 1)
                self.last_time_battery_state_changed_ = time_now
        elif self.batter_state_ == "empty":
            if time_now - self.last_time_battery_state_changed_ > 6.0:
                self.batter_state_ = "full"
                self.get_logger().info("Battery is  now full! ")
                # 电池满时关闭led
                self.call_set_led(2, 0)
                self.last_time_battery_state_changed_ = time_now

    # 调用服务
    def call_set_led(self, led_number, state):
        while not self.set_led_client_.wait_for_service(1.0):
            self.get_logger().warn("Waiting for Set Led service")
        request = SetLed.Request()
        request.led_number = led_number
        request.state = state

        # 异步调用
        future = self.set_led_client_.call_async(request)
        # 设置回调
        future.add_done_callback(self.callback_call_set_led)

    def callback_call_set_led(self, future):
        # 收到请求后
        # 添加类型后if那里才有自动补全
        response: SetLed.Response = future.result()
        if response.success:
            self.get_logger().info("LED state was changed")
        else:
            self.get_logger().info("LED not changed")


def main(args=None):
    rclpy.init(args=args)
    node = BatteryNode()
    rclpy.spin(node)
    rclpy.shutdown()


if __name__ == "__main__":
    main()

```

# 测试

```bash
╭─ ~/HelloROS2/ros2_ws main !2 ?4
╰─❯ ros2 run my_py_pkg led_panel
[INFO] [1791684056.629644168] [led_panel]: LED panel node has been started.

─ ~/HelloROS2/ros2_ws main !2 ?4
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
  
#启动电池节点，4秒后电池耗尽，6秒后电池充满
╭─ ~/HelloROS2/ros2_ws main !2 ?4
╰─❯ ros2 run my_py_pkg battery
[INFO] [1791684335.828478844] [battery]: Battery node has been started.
[INFO] [1791684337.993792422] [battery]: Battery is empty! Charging...
[INFO] [1791684338.005479090] [battery]: LED state was changed
[INFO] [1791684343.993919188] [battery]: Battery is  now full!
[INFO] [1791684343.999954274] [battery]: LED state was changed
[INFO] [1791684348.994165209] [battery]: Battery is empty! Charging...
[INFO] [1791684349.001081397] [battery]: LED state was changed
[INFO] [1791684355.993489144] [battery]: Battery is  now full!
[INFO] [1791684355.999533021] [battery]: LED state was changed
[INFO] [1791684359.993546631] [battery]: Battery is empty! Charging...
[INFO] [1791684360.001706437] [battery]: LED state was changed
[INFO] [1791684365.996529842] [battery]: Battery is  now full!
[INFO] [1791684366.001683090] [battery]: LED state was changed
[INFO] [1791684370.992653219] [battery]: Battery is empty! Charging...
  
#查看led状态
#╭─ ~/HelloROS2/ros2_ws main !2 ?4
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
- 0
- 0
- 0
---
led_status:
- 0
- 0
- 1
---
led_status:
- 0
- 0
- 1
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
- 0
- 0
- 1
---
led_status:
- 0
- 0
- 1
---
```



