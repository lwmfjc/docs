---
title: "0810额外_参数回调功能"
description: "0810额外_参数回调功能"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-12T11:03:36+08:00
lastmod: 2026-10-12T11:03:36+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
> 参数回调功能是可选的

> 回顾功能

```bash
#启动程序
╭─ ~/HelloROS2/ros2_ws main !1 ?2
╰─❯ ros2 run my_py_pkg number_publisher
[INFO] [1791774302.311855465] [number_publisher]: Number publisher has been started.


#查看参数
╭─ ~/HelloROS2/ros2_ws main !1 ?2
╰─❯ ros2 param list
/number_publisher:
  number
  start_type_description_service
  timer_period
  use_sim_time

╭─ ~/HelloROS2/ros2_ws main !1 ?2     4s
╰─❯ ros2 param get /number_publisher number
Integer value is: 2

╭─ ~/HelloROS2/ros2_ws main !1 ?2     3s
╰─❯

╭─ ~/HelloROS2/ros2_ws main !1 ?2
╰─❯ ros2 param get /number_publisher timer_period
Double value is: 1.0

#订阅者
╭─ ~/HelloROS2/ros2_ws main !1 ?2
╰─❯ ros2 topic echo /number
data: 2
---
data: 2
---
```

> 命令行修改参数

```bash
╭─ ~/HelloROS2/ros2_ws main !1 ?2
╰─❯ ros2 param set /number_publisher number 4
Set parameter successful

╭─ ~/HelloROS2/ros2_ws main !1 ?2
╰─❯ ros2 param get /number_publisher number
Integer value is: 4
```

# 但是订阅者收到的还是原来的值（2）

```bash
╭─ ~/HelloROS2/ros2_ws main !1 ?2
╰─❯ ros2 topic echo /number
data: 2
---
data: 2
---
```

# 添加参数回调完善功能

> 修改number_publisher.py

> 在 `__init__` 函数中添加参数回调设置

```python
        #在参数已经修改之后的回调
        self.add_post_set_parameters_callback(self.parameters_callback)
        #不是下面这个，这个需要返回 SetParametersResult 确认是否成功修改
        #self.add_on_set_parameters_callback(self.parameters_callback)
```

> 添加回调函数定义

```bash
    # 回调收到的参数对象是 list[Parameter] （Parameter是一个类型）
    # params对象有很多属性，比如
    # Parameter对象
    #    │
    #    ├── name
    #    │   speed
    #    │
    #    ├── type_
    #    │   Parameter.Type.INTEGER
    #    │
    #    └── value
    #        10
    def parameters_callback(self, params: list[Parameter]):
        for param in params:
            if param.name == "number":
                self.number_ = param.value
            # 如果要修改timer_period，需要先停止定时器之后再次创建启动它
            # 意思是有时候修改参数的值可能要做一些额外的操作
            
    
```

> 重新运行程序

```bash
╭─ ~/HelloROS2/ros2_ws main !2 ?2  ✘ INT
╰─❯ ros2 run my_py_pkg number_publisher  [INFO] [1791776188.847204932] [number_publisher]: Number publisher has been started.

╭─ ~/HelloROS2/ros2_ws main !2 ?2
╰─❯ ros2 topic echo /number
data: 2
---
data: 2
---
data: 2

#修改参数
╭─ ~/HelloROS2/ros2_ws main !2 ?2
╰─❯ ros2 param set /number_publisher number 4
Set parameter successful

#查看
#╭─ ~/HelloROS2/ros2_ws main !2 ?2
#╰─❯ ros2 topic echo /number
data: 2
---
data: 2
---
data: 2
---
data: 4
---
data: 4
---
data: 4
```

# number_publisher.cpp代码

```cpp
#include "rclcpp/rclcpp.hpp"
#include "example_interfaces/msg/int64.hpp"

// 如果使用1.0返回的是 具体的 std::chrono::duration<double>
using namespace std::chrono_literals;
//添加这个
using namespace std::placeholders;

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

        //添加这个
        param_callback_handle_ = this->add_post_set_parameters_callback(
            std::bind(&NumberPublisherNode::parametersCallback, this, _1));

        number_publisher_ = this->create_publisher<example_interfaces::msg::Int64>("number", 10);
        // 之前能用1.0是因为之前用了 using namespace std::chrono_literals;
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

    //添加这个
    void parametersCallback(const std::vector<rclcpp::Parameter> &parameters)
    {
        for (const auto &param : parameters)
        {
            if (param.get_name() == "number")
            {
                number_ = param.as_int();
            }
        }
    }

    int number_;
    rclcpp::Publisher<example_interfaces::msg::Int64>::SharedPtr number_publisher_;
    rclcpp::TimerBase::SharedPtr number_timer_;
    // 回调函数
    //添加这个
    PostSetParametersCallbackHandle::SharedPtr param_callback_handle_;
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

> 之后build,souce,run 一样的效果

```bash
╭─ ~/HelloROS2/ros2_ws main !2 ?2
╰─❯ colcon build --packages-select my_cpp_pkg
Starting >>> my_cpp_pkg
Finished <<< my_cpp_pkg [17.0s]

Summary: 1 package finished [17.6s]

╭─ ~/HelloROS2/ros2_ws main !3 ?2     
╰─❯ source install/setup.zsh

╭─ ~/HelloROS2/ros2_ws main !3 ?2
╰─❯ ros2 run my_cpp_pkg number_publisher [INFO] [1791776992.605793782] [number_publisher]: Number publisher has bee started.


```

```bash
╭─ ~/HelloROS2/ros2_ws main !3 ?2
╰─❯ ros2 topic echo /number
data: 2
---
data: 2
---
data: 2
---
data: 2

╭─ ~/HelloROS2/ros2_ws main !3 ?2
╰─❯ ros2 param set /number_publisher number 3
Set parameter successful




#╭─ ~/HelloROS2/ros2_ws main !3 ?2
#╰─❯ ros2 topic echo /number
data: 2
---
data: 2
---
data: 2
---
data: 2
---
data: 3
---
data: 3
```

> 查看服务

```bash
╭─ ~/HelloROS2/ros2_ws main !3 ?2
╰─❯ ros2 service list
/number_publisher/describe_parameters
/number_publisher/get_parameter_types
/number_publisher/get_parameters
/number_publisher/get_type_description
/number_publisher/list_parameters #获取参数
/number_publisher/set_parameters #设置参数
/number_publisher/set_parameters_atomically

```

```bash
ros2 param list /number_publisher
              |
              v
ROS2 CLI 查询节点参数
              |
              v
调用 service:
 /number_publisher/list_parameters
              |
              v
返回参数列表
```