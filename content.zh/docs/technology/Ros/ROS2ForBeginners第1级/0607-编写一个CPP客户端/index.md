---
title: "0607-编写一个CPP客户端"
description: "0607-编写一个CPP客户端"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-08T17:11:13+08:00
lastmod: 2026-10-08T17:11:13+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# CPP客户端-非面向对象方式

```cpp
#include "rclcpp/rclcpp.hpp"
#include "example_interfaces/srv/add_two_ints.hpp"

using namespace std::chrono_literals;

int main(int argc, char **argv)
{

    rclcpp::init(argc, argv);
    auto node = std::make_shared<rclcpp::Node>("add_two_ints_client_no_oop");
    auto client = node->create_client<example_interfaces::srv::AddTwoInts>("add_two_ints");
    while (client->wait_for_service(1.0s))
    {
        RCLCPP_INFO(node->get_logger(), "Waiting for the server...");
    }

    // 创建请求的共享指针
    auto request = std::make_shared<example_interfaces::srv::AddTwoInts::Request>();
    request->a = 6;
    request->b = 2;
    // 异步调用
    auto future = client->async_send_request(request);
    // 旋转节点直到future完成
    rclcpp::spin_until_future_complete(node, future);
    auto response = future.get();

    RCLCPP_INFO(node->get_logger(), "%d + %d = %d", (int)request->a, (int)request->b, (int)response->sum);

    rclcpp::shutdown();
    return 0;
}
```

> 添加可执行程序

> CMakeList.txt修改

```bash

#添加两行
add_executable(add_two_ints_client src/add_two_ints_client_no_oop.cpp)
ament_target_dependencies(add_two_ints_client rclcpp example_interfaces)

#安装
#将可执行文件安装到 lib/${PROJECT_NAME}
install(TARGETS
  cpp_node
  robot_news_station #再添加一个可执行文件
  smartphone
  add_two_ints_server
  #添加下面那行
  add_two_ints_client
  DESTINATION lib/${PROJECT_NAME}
)
```

> build，source，run

```bash

```