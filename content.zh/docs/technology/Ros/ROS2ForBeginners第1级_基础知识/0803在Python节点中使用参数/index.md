---
title: "0803在Python节点中使用参数"
description: "0803在Python节点中使用参数"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-11T16:06:14+08:00
lastmod: 2026-10-11T16:06:14+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 在Python节点中使用参数

> 在Python节点中创建一个参数，以及使用它

> 本课程复用原来的节点，不会创建新节点

使用number_publisher.py这个文件  

> 目前的功能是每秒发布一个 2 （2是硬编码的）

> 修改后的 number_publish.py

```python
#!/usr/bin/env python3
import rclpy
from rclpy.node import Node
from example_interfaces.msg import Int64


class NumberPublisherNode(Node):
    def __init__(self):
        super().__init__("number_publisher")
        # 声明参数
        # 每当声明一个参数就会在节点内部注册一个参数
        # 为节点创建一个number参数，默认值为2
        # 会使用默认值提供的类型
        self.declare_parameter("number", 2)
        self.declare_parameter("timer_period", 1.0)

        # 获取参数，.get_parameter()返回的是参数对象
        self.number_ = self.get_parameter("number").value
        self.timer_period_ = self.get_parameter("timer_period").value

        # 创建发布者
        # 类型、名称、队列大小
        self.number_publisher_ = self.create_publisher(Int64, "number", 10)
        # 每1.0秒调用一次
        self.number_timer = self.create_timer(self.timer_period_, self.publish_number)
        self.get_logger().info("Number publisher has been started.")

    def publish_number(self):
        msg = Int64()
        msg.data = self.number_
        self.number_publisher_.publish(msg)


def main(args=None):
    rclpy.init(args=args)
    node = NumberPublisherNode()
    rclpy.spin(node)
    rclpy.shutdown()


if __name__ == "__main__":
    main()


```

> build,source,run

```bash
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ colcon build --packages-select my_py_pkg --symlink-install
Starting >>> my_py_pkg
Finished <<< my_py_pkg [7.87s]

Summary: 1 package finished [8.64s]

╭─ ~/HelloROS2/ros2_ws main !1 ?1         
╰─❯ source install/setup.zsh

╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 run my_py_pkg number_publisher
[INFO] [1791706617.346335408] [number_publisher]: Number publisher has been started.
```

> 查看节点存在的所有参数


```bash
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 param list
/number_publisher:
  number
  start_type_description_service
  timer_period
  use_sim_time
  
  #每秒收到一个2
╭─ ~/HelloROS2/ros2_ws main !1 ?1     4s
╰─❯ ros2 topic echo /number
data: 2
---
data: 2
---
data: 2
---
data: 2
---
data: 2

```

> run时修改参数值

```bash
─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 run my_py_pkg number_publisher --ros-args -p number:=3 -p timer_period:=0.5
[INFO] [1791706891.164618237] [number_publisher]: Number publisher has been started.
```

> 每0.5秒发布一个3

```bash
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 topic echo /number              data: 3
---
data: 3
---
data: 3
---
data: 3
---
```

> 可以只提供一个参数值

> 下面是每1秒发布一次5

```bash
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 run my_py_pkg number_publisher --ros-args -p number:=5                   [INFO] [1791706980.312932336] [number_publisher]: Number publisher has been started.
```

> 如果数据类型不对则启动时会出错

```bash
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 run my_py_pkg number_publisher --ros-args -p number:=3.14
Traceback (most recent call last):
  File "/home/ly/HelloROS2/ros2_ws/install/my_py_pkg/lib/my_py_pkg/number_publisher", line 33, in <module>
    sys.exit(load_entry_point('my-py-pkg', 'console_scripts', 'number_publisher')())
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/ly/HelloROS2/ros2_ws/build/my_py_pkg/my_py_pkg/number_publisher.py", line 36, in main
    node = NumberPublisherNode()
           ^^^^^^^^^^^^^^^^^^^^^
  File "/home/ly/HelloROS2/ros2_ws/build/my_py_pkg/my_py_pkg/number_publisher.py", line 14, in __init__
    self.declare_parameter("number", 2)
  File "/opt/ros/jazzy/lib/python3.12/site-packages/rclpy/node.py", line 389, in declare_parameter
    return self.declare_parameters('', [args], ignore_override)[0]
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/opt/ros/jazzy/lib/python3.12/site-packages/rclpy/node.py", line 528, in declare_parameters
    self._declare_parameter_common(
  File "/opt/ros/jazzy/lib/python3.12/site-packages/rclpy/node.py", line 584, in _declare_parameter_common
    raise InvalidParameterTypeException(
rclpy.exceptions.InvalidParameterTypeException: Trying to set parameter 'number' to '3.14' of type 'DOUBLE', expecting type 'INTEGER': number
[ros2run]: Process exited with failure 1

```

# 在C++节点中使用参数

## 活动（练习）中的代码

> 这是活动（练习）中的代码，这里我没有，先补充一下

> number_publisher.cpp

```cpp
#include "rclcpp/rclcpp.hpp"
#include "example_interfaces/msg/int64.hpp"

using namespace std::chrono_literals;

class NumberPublisherNode : public rclcpp::Node
{

public:
    NumberPublisherNode() : Node("number_publisher"), number_(2)
    {
        number_publisher_ = this->create_publisher<example_interfaces::msg::Int64>("number", 10);
        number_timer_ = this->create_wall_timer(1s, std::bind(&NumberPublisherNode::publisherNumber, this));

        RCLCPP_INFO(this->get_logger(), "Number publisher has bee started.");
    }

private:
    void publisherNumber()
    {
        auto msg = example_interfaces::msg::Int64();
        msg.data = number_;
        number_publisher_->publish(msg);
    }
    int number_;
    rclcpp::Publisher<example_interfaces::msg::Int64>::SharedPtr number_publisher_;
    rclcpp::TimerBase::SharedPtr number_timer_;
};

int main(int argc, char **argv)
{

    rclcpp::init(argc, argv);
    auto node = std::make_shared<NumberPublisherNode>();
    rclcpp::spin(node);
    rclcpp::shutdown();
    return 0;
}
```

> CMakeList.txt

```cmake

add_executable(number_publisher src/number_publisher.cpp)
ament_target_dependencies(number_publisher rclcpp example_interfaces)


#安装
#将可执行文件安装到 lib/${PROJECT_NAME}
install(TARGETS
  #......省略了
  #添加这个
  number_publisher
  DESTINATION lib/${PROJECT_NAME}
)
```

> build,source,run

```bash
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ colcon build --packages-select my_cpp_pkg
Starting >>> my_cpp_pkg
Finished <<< my_cpp_pkg [21.7s]

Summary: 1 package finished [22.2s]

╭─ ~/HelloROS2/ros2_ws main !1 ?1    25s
╰─❯ source install/setup.zsh

╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 run my_cpp_pkg number_publisher [INFO] [1791708270.230550142] [number_publisher]: Number publisher has bee started.


#订阅者
╭─ ~/HelloROS2/ros2_ws main !1
╰─❯ ros2 topic echo /number          
data: 2
---
data: 2
---
data: 2
```

## 修改为使用参数的版本

```cpp
#include "rclcpp/rclcpp.hpp"
#include "example_interfaces/msg/int64.hpp"

//如果使用1.0返回的是 具体的 std::chrono::duration<double>
using namespace std::chrono_literals;

class NumberPublisherNode : public rclcpp::Node
{

public:
    NumberPublisherNode() : Node("number_publisher")
    {
        // 使用了默认值，也默认设置了该参数的类型
        this->declare_parameter("number", 2);
        this->declare_parameter("timer_period", 1.0);

        number_ = this->get_parameter("number").as_int();
        double timer_period_ = this->get_parameter("timer_period").as_double();

        number_publisher_ = this->create_publisher<example_interfaces::msg::Int64>("number", 10);
        //之前能用1.0是因为之前用了 using namespace std::chrono_literals;
        number_timer_ = this->create_wall_timer(std::chrono::duration<double>(timer_period_), std::bind(&NumberPublisherNode::publisherNumber, this));

        RCLCPP_INFO(this->get_logger(), "Number publisher has bee started.");
    }

private:
    void publisherNumber()
    {
        auto msg = example_interfaces::msg::Int64();
        msg.data = number_;
        number_publisher_->publish(msg);
    }
    int number_;
    rclcpp::Publisher<example_interfaces::msg::Int64>::SharedPtr number_publisher_;
    rclcpp::TimerBase::SharedPtr number_timer_;
};

int main(int argc, char **argv)
{

    rclcpp::init(argc, argv);
    auto node = std::make_shared<NumberPublisherNode>();
    rclcpp::spin(node);
    rclcpp::shutdown();
    return 0;
}
```

> build,source ,run 

```bash
╭─ ~/HelloROS2/ros2_ws main !1
╰─❯ colcon build --packages-select my_cpp_pkg
Starting >>> my_cpp_pkg
Finished <<< my_cpp_pkg [16.2s]

Summary: 1 package finished [16.6s]

╭─ ~/HelloROS2/ros2_ws main !1          
╰─❯ source install/setup.zsh


```

> 测试

```bash
╭─ ~/HelloROS2/ros2_ws main !1
╰─❯ ros2 run my_cpp_pkg number_publisher
[INFO] [1791709395.653972124] [number_publisher]: Number publisher has bee started.

╭─ ~/HelloROS2/ros2_ws main !1
╰─❯ ros2 topic echo /number
data: 2
---
data: 2
---
data: 2

#查看参数列表
╭─ ~/HelloROS2/ros2_ws main !1
╰─❯ ros2 param list
/number_publisher:
  number
  qos_overrides./parameter_events.publisher.depth
  qos_overrides./parameter_events.publisher.durability
  qos_overrides./parameter_events.publisher.history
  qos_overrides./parameter_events.publisher.reliability
  start_type_description_service
  timer_period
  use_sim_time

```

> 设置参数

```bash
#每3.4秒发布一次数字20
╭─ ~/HelloROS2/ros2_ws main !1     ✘ 250
╰─❯ ros2 run my_cpp_pkg number_publisher --ros-args -p number:=20 -p timer_period:=3.4
[INFO] [1791709544.155566748] [number_publisher]: Number publisher has bee started.

╭─ ~/HelloROS2/ros2_ws main !1
╰─❯ ros2 topic echo /number
data: 20
---
data: 20
---
data: 20
---
```

> 提供不存在的参数也不会导致报错

```bash
╭─ ~/HelloROS2/ros2_ws main !1       34s
╰─❯ ros2 run my_cpp_pkg number_publisher --ros-args -p number:=20 -p this_param_not_exist:=3.4
[INFO] [1791709664.091911819] [number_publisher]: Number publisher has bee started.

#提供的错误参数不影响 param list
╭─ ~/HelloROS2/ros2_ws main !1
╰─❯ ros2 param list
/number_publisher:
  number
  qos_overrides./parameter_events.publisher.depth
  qos_overrides./parameter_events.publisher.durability
  qos_overrides./parameter_events.publisher.history
  qos_overrides./parameter_events.publisher.reliability
  start_type_description_service
  timer_period
  use_sim_time
```