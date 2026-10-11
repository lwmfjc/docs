---
title: "0606-编写一个CPP服务器"
description: "0606-编写一个CPP服务器"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-08T12:08:42+08:00
lastmod: 2026-10-08T12:08:42+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
> 查看接口定义

```bash
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 interface show example_interfaces/srv/AddTwoInts
int64 a
int64 b
---
int64 sum
```

```bash
╭─ ~/HelloROS2/ros2_ws main
╰─❯ cd src/my_cpp_pkg/src

╭─ ~/HelloROS2/ros2_ws/src/my_cpp_pkg/src main
╰─❯ ls
my_first_node.cpp  robot_news_station.cpp  smartphone.cpp  template_cpp_node.cpp

╭─ ~/HelloROS2/ros2_ws/src/my_cpp_pkg/src main
╰─❯ touch add_two_ints_server.cpp
```

```c++
#include "rclcpp/rclcpp.hpp"
#include "example_interfaces/srv/add_two_ints.hpp"
using namespace std::placeholders;

class AddTwoIntsServerNode : public rclcpp::Node
{

public:
    AddTwoIntsServerNode() : Node("add_two_ints_server")
    {
        // 回调：需要使用std::bind
        // ROS2 Service 的回调约定就是类似：callback(request, response)
        server_ = this->create_service<example_interfaces::srv::AddTwoInts>(
            "add_two_ints", std::bind(&AddTwoIntsServerNode::callbackAddTwoInts, this, _1, _2));
        RCLCPP_INFO(this->get_logger(), "Add Two Ints Service has been started.");
    }

private:
    rclcpp::Service<example_interfaces::srv::AddTwoInts>::SharedPtr server_;

    void callbackAddTwoInts(const example_interfaces::srv::AddTwoInts::Request::SharedPtr request,
                            const example_interfaces::srv::AddTwoInts::Response::SharedPtr response)
    {
        response->sum = request->a + request->b;
        // request->a 是 int64_t，而 %d 期待 int，所以显式转换成 int。
        // 不过，直接强转成 int 有潜在的数据截断问题
        RCLCPP_INFO(this->get_logger(), "%d + %d = %d",(int)request->a,
                    (int)request->b, (int)response->sum);
    }
};

int main(int argc, char **argv)
{

    rclcpp::init(argc, argv);
    auto node = std::make_shared<AddTwoIntsServerNode>();
    rclcpp::spin(node);
    rclcpp::shutdown();
    return 0;
}
```

> CMakeList.txt 添加可执行文件

```cmake
#添加这个2
add_executable(add_two_ints_server src/add_two_ints_server.cpp)
ament_target_dependencies(add_two_ints_server rclcpp example_interfaces)

#安装
#将可执行文件安装到 lib/${PROJECT_NAME}
install(TARGETS
  cpp_node
  robot_news_station #再添加一个可执行文件
  smartphone
  #添加这个2
  add_two_ints_server
  DESTINATION lib/${PROJECT_NAME}
)
```

> build,source,run

```bash
╭─ ~/HelloROS2/ros2_ws main !2
╰─❯ colcon build --packages-select my_cpp_pkg
Starting >>> my_cpp_pkg
Finished <<< my_cpp_pkg [12.7s]

Summary: 1 package finished [13.1s]


╭─ ~/HelloROS2/ros2_ws main !2    
╰─❯ source install/setup.zsh


```

> 运行，查看

```bash
╭─ ~/HelloROS2/ros2_ws main !2
╰─❯ ros2 run my_cpp_pkg add_two_ints_server
[INFO] [1791448751.254162461] [add_two_ints_server]: Add Two Ints Service has been started.

╭─ ~/HelloROS2/ros2_ws main !2
╰─❯ ros2 service list
/add_two_ints #我们启动的服务
/add_two_ints_server/describe_parameters
/add_two_ints_server/get_parameter_types
/add_two_ints_server/get_parameters
/add_two_ints_server/get_type_description
/add_two_ints_server/list_parameters
/add_two_ints_server/set_parameters
/add_two_ints_server/set_parameters_atomically

```

> 启动Python版的客户端

```bash
╭─ ~/HelloROS2/ros2_ws main !2
╰─❯ ros2 run my_py_pkg add_two_ints_client_no_oop
[INFO] [1791448889.744143847] [add_two_ints_client_no_oop]: 3 + 8 = 11

#查看服务器收到的请求及日志
#╭─ ~/HelloROS2/ros2_ws main !2
#╰─❯ ros2 run my_cpp_pkg add_two_ints_server
[INFO] [1791448751.254162461] [add_two_ints_server]: Add Two Ints Service has been started.
[INFO] [1791448889.713236199] [add_two_ints_server]: 3 + 8 = 11
```

