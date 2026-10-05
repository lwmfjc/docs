---
title: "0505-"
description: "0505-"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-05T16:15:13+08:00
lastmod: 2026-10-05T16:15:13+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 编写CPP发布者

```bash
╭─ ~/HelloROS2/ros2_ws/src/my_cpp_pkg main
╰─❯ ls
CMakeLists.txt  include  package.xml  src

╭─ ~/HelloROS2/ros2_ws/src/my_cpp_pkg main
╰─❯ cd src

#进入cpp包源代码文件夹
╭─ ~/HelloROS2/ros2_ws/src/my_cpp_pkg/src main
╰─❯ ls
my_first_node.cpp

╭─ ~/HelloROS2/ros2_ws/src/my_cpp_pkg/src main
╰─❯ touch robot_news_station.cpp
```

## 模版类

```cpp
#include "rclcpp/rclcpp.hpp"

class MyCustomNode : public rclcpp::Node //MODIFY NAME
{

public:

    MyCustomNode() : Node("node_name") //MODIFY NAME
    {
    }

private: 
};

int main(int argc, char **argv)
{
    
    rclcpp::init(argc, argv);
    auto node = std::make_shared<MyCustomNode>();//MODIFY NAME
    rclcpp::spin(node); 
    rclcpp::shutdown();
    return 0;
}
```

## robot_news_station.cpp

```bash
#这个接口可以在Python中使用，当然也可以在C++中使用
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 interface show example_interfaces/msg/String
# This is an example message of using a primitive datatype, string.
# If you want to test with this that's fine, but if you are deploying
# it into a system you should create a semantically meaningful message type.
# If you want to embed it in another message, use the primitive data type instead.
string data
```

> 拷贝模版类并进行编辑

> 由于使用了`#include "example_interfaces/msg/string.hpp"`，所以需要在package.xml中添加依赖

```xml 
  <!--声明依赖关系，声明“我的包依赖 example_interfaces”-->
  <depend>example_interfaces</depend> 
```

> CMakeList.txt添加依赖项

```cmake
#将依赖项链接到可执行文件时也要使用它
#查找并配置依赖
#找到已经安装的 example_interfaces，并把它提供的 CMake 配置信息加载进来。
find_package(example_interfaces REQUIRED)
```

> package.xml 管“我依赖谁”，CMakeLists.txt 管“编译时怎么使用这个依赖”。

> 修改robot_news_station.cpp

```cpp
#include "rclcpp/rclcpp.hpp"
#include "example_interfaces/msg/string.hpp"

using namespace std::chrono_literals;

class RobotNewsStationNode : public rclcpp::Node //MODIFY NAME
{

public:

    //节点名
    RobotNewsStationNode() : Node("robot_news_station"),robot_name("R2D2")
    {
        //创建发布者
        publisher_=this->create_publisher<example_interfaces::msg::String>("robot_news",10);
        //初始化定时器，绑定函数(因为这个函数非静态，所以需要对象才能调用)
        timer_=this->create_wall_timer(0.5s,std::bind(&RobotNewsStationNode::publishNews,this));
        //添加日志表示已经启动
        //RCLCPP_INFO 这是一个 ROS 2 提供的日志宏 INFO 表示日志级别是「普通信息」
        //this->get_logger() 获取当前 ROS 2 节点的 Logger（日志器）
        RCLCPP_INFO(this->get_logger(),"Robot News Station has been started");
    }

private: 
    void publishNews()
    {
        //这里直接是对象本身而不是共享指针
        auto msg=example_interfaces::msg::String();
        msg.data= std::string("Hi,this is ") +robot_name+std::string(" from the robot news station.");
        publisher_->publish(msg);
    }
    std::string robot_name;
    //ROS2中所有东西都使用共享指针
    rclcpp::Publisher<example_interfaces::msg::String>::SharedPtr publisher_;

    //创建一个定时器
    rclcpp::TimerBase::SharedPtr timer_;
};

int main(int argc, char **argv)
{
    
    rclcpp::init(argc, argv);
    auto node = std::make_shared<RobotNewsStationNode>();//MODIFY NAME
    rclcpp::spin(node); 
    rclcpp::shutdown();
    return 0;
}
```

> CMakeList.txt添加可执行文件及其依赖项、以及install添加一个可执行文件

```cmake
#再添加可执行文件及其依赖
add_executable(robot_news_station src/robot_news_station.cpp)
ament_target_dependencies(robot_news_station rclcpp example_interfaces)

#安装
#将可执行文件安装到 lib/${PROJECT_NAME}
install(TARGETS
  cpp_node
  robot_news_station #再添加一个可执行文件
  DESTINATION lib/${PROJECT_NAME}
)
```
##  build,source,run

```bash
╭─ ~/HelloROS2/ros2_ws main !2 ?2
╰─❯ colcon build --packages-select my_cpp_pkg
Starting >>> my_cpp_pkg
Finished <<< my_cpp_pkg [19.3s]

Summary: 1 package finished [19.8s]

╭─ ~/HelloROS2/ros2_ws main !2 ?2
╰─❯ source install/setup.zsh


```

> 运行、查看

```bash
╭─ ~
╰─❯ ros2 run my_cpp_pkg robot_news_station
[INFO] [1791191819.562298767] [robot_name_station]: Robot News Station has been started


╭─ ~
╰─❯ ros2 node list
/robot_news_station

╭─ ~
╰─❯ ros2 node info /robot_news_station
/robot_news_station
  Subscribers:
    /parameter_events: rcl_interfaces/msg/ParameterEvent
  Publishers:
    /parameter_events: rcl_interfaces/msg/ParameterEvent
    #发布者，接口example_interfaces/msg/String
    /robot_news: example_interfaces/msg/String
    /rosout: rcl_interfaces/msg/Log
  Service Servers:
    /robot_news_station/describe_parameters: rcl_interfaces/srv/DescribeParameters
    /robot_news_station/get_parameter_types: rcl_interfaces/srv/GetParameterTypes
    /robot_news_station/get_parameters: rcl_interfaces/srv/GetParameters
    /robot_news_station/get_type_description: type_description_interfaces/srv/GetTypeDescription
    /robot_news_station/list_parameters: rcl_interfaces/srv/ListParameters
    /robot_news_station/set_parameters: rcl_interfaces/srv/SetParameters
    /robot_news_station/set_parameters_atomically: rcl_interfaces/srv/SetParametersAtomically
  Service Clients:

  Action Servers:

  Action Clients:


```

## 订阅

> 直接在终端订阅

```bash
╭─ ~/HelloROS2/ros2_ws main !2 ?2
╰─❯ ros2 topic echo /robot_news
data: Hi,this is R2D2 from the robot news station.
---
data: Hi,this is R2D2 from the robot news station.
---
data: Hi,this is R2D2 from the robot news station.
---

```

> 或者启动之前的Python订阅者节点
> 因为他和cpp发布者具有相同的话题名称以及对应的数据类型（接口）

```bash
╭─ ~/HelloROS2/ros2_ws main !2 ?2
╰─❯ ros2 run my_py_pkg smartphone
[INFO] [1791192214.271501978] [smartphone]: Smartphone has been started.
[INFO] [1791192214.693985063] [smartphone]: Hi,this is R2D2 from the robot news station.
[INFO] [1791192215.194986358] [smartphone]: Hi,this is R2D2 from the robot news station.

```

> 即ROS是与语言无关的，可以创建一个C++节点、一个Python节点，两个节点都可以使用例如主题进行通信

# 编写C++订阅者

