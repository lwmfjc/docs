---
title: "0607-0608编写一个CPP客户端(非面向对象方式、面向对象方式)"
description: "0607-0608编写一个CPP客户端(非面向对象方式、面向对象方式)"
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
    
    //如果 1.0 秒内找到了 Service，则返回True；没找到则False
    while (!client->wait_for_service(1.0s))
    {
        RCLCPP_WARN(node->get_logger(), "Waiting for the server...");
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
╭─ ~/HelloROS2 main
╰─❯ cd ros2_ws

╭─ ~/HelloROS2/ros2_ws main
╰─❯ colcon build --packages-select my_cpp_pkg
Starting >>> my_cpp_pkg
Finished <<< my_cpp_pkg [16.3s]

Summary: 1 package finished [16.9s]

#运行客户端
╭─ ~/HelloROS2/ros2_ws main !1
╰─❯ ros2 run my_cpp_pkg add_two_ints_client
[WARN] [1791454213.012724727] [add_two_ints_client_no_oop]: Waiting for the server...
[WARN] [1791454214.013535048] [add_two_ints_client_no_oop]: Waiting for the server...
[WARN] [1791454215.013958463] [add_two_ints_client_no_oop]: Waiting for the server...
[WARN] [1791454216.014363693] [add_two_ints_client_no_oop]: Waiting for the server...


#运行服务端
╭─ ~/HelloROS2/ros2_ws main !1
╰─❯ ros2 run my_cpp_pkg add_two_ints_server
[INFO] [1791454216.253194004] [add_two_ints_server]: Add Two Ints Service has been started.
[INFO] [1791454217.696478460] [add_two_ints_server]: 6 + 2 = 8

#查看客户端
#╭─ ~/HelloROS2/ros2_ws main !1
#╰─❯ ros2 run my_cpp_pkg add_two_ints_client
[WARN] [1791454213.012724727] [add_two_ints_client_no_oop]: Waiting for the server...
[WARN] [1791454214.013535048] [add_two_ints_client_no_oop]: Waiting for the server...
[WARN] [1791454215.013958463] [add_two_ints_client_no_oop]: Waiting for the server...
[WARN] [1791454216.014363693] [add_two_ints_client_no_oop]: Waiting for the server...
[INFO] [1791454217.697692250] [add_two_ints_client_no_oop]: 6 + 2 = 8


```

> add_two_ints_client_no_oop.cpp 对快速测试服务非常有用；如果有你有一个service server，且请求有点太复杂而无法在终端使用，那么就使用这个作为模版，可以直接测试你的服务器

> 目前这个add_two_ints_client_no_oop.cpp 运行后，Ctrl+C会出问题 ~~目前先不处理，不是重点。（主要是解决方式目前的知识不够用）~~ 



# CPP客户端-面向对象方式

> 直接在采用面向对象编程编写的节点中，编写一个C++ service client

> 主要是学习，如何将service client集成到现有节点中，该节点可能包含例如发布者、订阅者、其他服务等。所以要在节点内部重写这部分代码

> 创建一个新的节点

```bash
╭─ ~/HelloROS2/ros2_ws/src/my_cpp_pkg/src main
╰─❯ touch add_two_ints_client.cpp
```

> 代码

```cpp
#include "rclcpp/rclcpp.hpp"
#include "example_interfaces/srv/add_two_ints.hpp"

using namespace std::chrono_literals;
using namespace std::placeholders;

class AddIntClientNode : public rclcpp::Node
{

public:
    AddIntClientNode() : Node("add_int_client")
    {
        client_ = this->create_client<example_interfaces::srv::AddTwoInts>("add_two_ints");
    }

    void callAddTwoInts(int a, int b)
    {
        // 等待服务器启动
        while (!client_->wait_for_service(1s))
        {
            RCLCPP_WARN(this->get_logger(), "Waiting for the server...");
        }

        auto request = std::make_shared<example_interfaces::srv::AddTwoInts::Request>();
        request->a = a;
        request->b = b;

        // 如果想要添加其他参数给回调函数（callbackCallAddTwoInts），
        // 可以把参数放到类属性中，然后在callbackCallAddTwoInts中
        // 直接访问即可
        //  异步发送请求,设置收到回应后的回调函数
        auto future = client_->async_send_request(request,
                                                  std::bind(&AddIntClientNode::callbackCallAddTwoInts, this, _1));
    }

private:
    rclcpp::Client<example_interfaces::srv::AddTwoInts>::SharedPtr client_;
    void callbackCallAddTwoInts(rclcpp::Client<example_interfaces::srv::AddTwoInts>::SharedFuture future)
    {
        auto response = future.get();
        RCLCPP_INFO(this->get_logger(), "Sum: %d", (int)response->sum);
    }
};

int main(int argc, char **argv)
{

    rclcpp::init(argc, argv);
    auto node = std::make_shared<AddIntClientNode>();
    node->callAddTwoInts(10, 5);
    rclcpp::spin(node);
    rclcpp::shutdown();
    return 0;
}
```

> 添加可执行文件，安装它

```cmake

#新增1：添加可执行文件
add_executable(add_two_ints_client src/add_two_ints_client.cpp)
ament_target_dependencies(add_two_ints_client rclcpp example_interfaces)

#安装
#将可执行文件安装到 lib/${PROJECT_NAME}
install(TARGETS
  cpp_node
  robot_news_station #再添加一个可执行文件
  smartphone
  add_two_ints_server
  add_two_ints_client_no_oop
  #新增2 安装它
  add_two_ints_client
  DESTINATION lib/${PROJECT_NAME}
)
```

> buld，source，run

```bash
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ colcon build --packages-select my_cpp_pkg
Starting >>> my_cpp_pkg
Finished <<< my_cpp_pkg [16.5s]

Summary: 1 package finished [17.1s]

╭─ ~/HelloROS2/ros2_ws main !1 ?1    
╰─❯ source install/setup.zsh

#启动客户端（等待服务器）
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 run my_cpp_pkg add_two_ints_client
[WARN] [1791463756.846452825] [add_int_client]: Waiting for the server...
[WARN] [1791463757.847377352] [add_int_client]: Waiting for the server...
[WARN] [1791463758.847764578] [add_int_client]: Waiting for the server...
[WARN] [1791463803.362814978] [add_int_client]: Waiting for the server...


#启动服务端
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 run my_cpp_pkg add_two_ints_server
[INFO] [1791463803.492311076] [add_two_ints_server]: Add Two Ints Service has been started.
[INFO] [1791463804.950953571] [add_two_ints_server]: 10 + 5 = 15

#查看客户端
#╭─ ~/HelloROS2/ros2_ws main !1 ?1
#╰─❯ ros2 run my_cpp_pkg add_two_ints_client
[WARN] [1791463756.846452825] [add_int_client]: Waiting for the server...
[WARN] [1791463757.847377352] [add_int_client]: Waiting for the server...
[WARN] [1791463758.847764578] [add_int_client]: Waiting for the server...
[WARN] [1791463803.362814978] [add_int_client]: Waiting for the server...
[INFO] [1791463804.952086496] [add_int_client]: Sum: 15

```

> 修改`add_two_ints_client.cpp`中的main函数

```cpp
int main(int argc, char **argv)
{

    rclcpp::init(argc, argv);
    auto node = std::make_shared<AddIntClientNode>();
    node->callAddTwoInts(10, 5);
    #添加下面两个客户端调用
    node->callAddTwoInts(12, 7);
    node->callAddTwoInts(1, 2);
    rclcpp::spin(node);
    rclcpp::shutdown();
    return 0;
}
```

> build,source,run

```bash
#构建工作空间中的包，并生成安装空间 `install/`
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ colcon build --packages-select my_cpp_pkg
Starting >>> my_cpp_pkg
Finished <<< my_cpp_pkg [12.2s]

Summary: 1 package finished [12.5s]


#把这个工作空间的环境加载到当前 Shell
╭─ ~/HelloROS2/ros2_ws main !1 ?1     
╰─❯ source install/setup.zsh

```

```bash
#运行服务端
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 run my_cpp_pkg add_two_ints_server
[INFO] [1791464422.895840366] [add_two_ints_server]: Add Two Ints Service has been started.

#运行客户端
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 run my_cpp_pkg add_two_ints_client
[WARN] [1791464467.889317342] [add_int_client]: Waiting for the server...
[INFO] [1791464468.353689939] [add_int_client]: Sum: 15
[INFO] [1791464468.354084018] [add_int_client]: Sum: 19
[INFO] [1791464468.354992848] [add_int_client]: Sum: 3
```