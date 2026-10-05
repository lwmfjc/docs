---
title: "0505-0506编写CPP发布者和订阅者"
description: "0505-0506编写CPP发布者和订阅者"
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
  <!--例如别人拿到你的包，在另一台电脑上安装依赖时，可以根据 package.xml 知道应该安装什么-->
  <depend>example_interfaces</depend> 
```

> CMakeList.txt添加依赖项

```cmake
#将依赖项链接到可执行文件时也要使用它
#查找并配置依赖
#找到已经安装的 example_interfaces，并把它提供的 CMake 配置信息加载进来。
find_package(example_interfaces REQUIRED)
```

> 1. package.xml 管“我依赖谁”，声明"我需要它"，是元数据。
> 2. CMakeLists.txt 管“编译时怎么使用这个依赖”，"怎么把这个依赖用进编译过程"，是构建层面的查找和使用。 ~~在当前构建过程中，找到 example_interfaces 这个包，并加载它的 CMake 配置（通常是 example_interfacesConfig.cmake~~ 

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

```bash
╭─ ~/HelloROS2/ros2_ws/src/my_cpp_pkg/src main !1
╰─❯ touch smartphone.cpp
```

```cpp
#include "rclcpp/rclcpp.hpp"
#include "example_interfaces/msg/string.hpp"

using namespace std::placeholders;

class SmartphoneNode : public rclcpp::Node
{

public:
    SmartphoneNode() : Node("smartphone")
    {
        //创建发布者，绑定回调
        //一个参数
        subsciber_ = this->create_subscription<example_interfaces::msg::String>("robot_news", 10, std::bind(&SmartphoneNode::callbackRobotNews, this,_1));
        //如果是两个参数
        //subsciber_ = this->create_subscription<example_interfaces::msg::String>("robot_news", 10, std::bind(&SmartphoneNode::callbackRobotNews, this,std::placeholders::_1,std::placeholders::_2));

        RCLCPP_INFO(this->get_logger(),"Smartphone has been started.");
    }

private:
    // ROS2中所有接口都可以使用SharedPtr来使用
    //接收到的消息是一个共享指针
    void callbackRobotNews(const example_interfaces::msg::String::SharedPtr msg)
    {
        // msg->data是一个std::string，这里配合RCLCPP_INFO所以
        // 需要转为c-string
        RCLCPP_INFO(this->get_logger(), "%s", msg->data.c_str());
    }

    rclcpp::Subscription<example_interfaces::msg::String>::SharedPtr subsciber_;
};

int main(int argc, char **argv)
{

    rclcpp::init(argc, argv);
    auto node = std::make_shared<SmartphoneNode>();
    rclcpp::spin(node);
    rclcpp::shutdown();
    return 0;
}
```

> CMakeLists.txt 添加一个新的可执行文件、依赖、安装

```cmake

add_executable(smartphone src/smartphone.cpp)
ament_target_dependencies(smartphone rclcpp example_interfaces)

#安装
#将可执行文件安装到 lib/${PROJECT_NAME}
install(TARGETS
  cpp_node
  robot_news_station #再添加一个可执行文件
  smartphone
  DESTINATION lib/${PROJECT_NAME}
)
```

## build,source,run

```bash
╭─ ~/HelloROS2/ros2_ws main !1
╰─❯ colcon build --packages-select my_cpp_pkg
Starting >>> my_cpp_pkg
                                         Finished <<< my_cpp_pkg [28.6s]

Summary: 1 package finished [29.0s]

╭─ ~/HelloROS2/ros2_ws main !1       32s
╰─❯ source install/setup.zsh
```

> 运行、查看

```bash
╭─ ~/HelloROS2/ros2_ws main !1
╰─❯ ros2 run my_cpp_pkg smartphone
[INFO] [1791198435.035275452] [smartphone]: Smartphone has been started.

```

```bash
#另一个终端
╭─ ~/HelloROS2/ros2_ws main !1
╰─❯ ros2 node list
/smartphone

╭─ ~/HelloROS2/ros2_ws main !1
╰─❯ ros2 node info /smartphone
/smartphone
  Subscribers:
    /parameter_events: rcl_interfaces/msg/ParameterEvent
    #订阅者
    /robot_news: example_interfaces/msg/String
  Publishers:
    /parameter_events: rcl_interfaces/msg/ParameterEvent
    /rosout: rcl_interfaces/msg/Log
  Service Servers:
    /smartphone/describe_parameters: rcl_interfaces/srv/DescribeParameters
    /smartphone/get_parameter_types: rcl_interfaces/srv/GetParameterTypes
    /smartphone/get_parameters: rcl_interfaces/srv/GetParameters
    /smartphone/get_type_description: type_description_interfaces/srv/GetTypeDescription
    /smartphone/list_parameters: rcl_interfaces/srv/ListParameters
    /smartphone/set_parameters: rcl_interfaces/srv/SetParameters
    /smartphone/set_parameters_atomically: rcl_interfaces/srv/SetParametersAtomically
  Service Clients:

  Action Servers:

  Action Clients:


```

> 运行CPP发布者

```bash
╭─ ~/HelloROS2/ros2_ws main !1
╰─❯ ros2 run my_cpp_pkg robot_news_station
[INFO] [1791198557.844086619] [robot_news_station]: Robot News Station has been started
^C[INFO] [1791198562.333597975] [rclcpp]: signal_handler(SIGINT/SIGTERM)
```

> 查看订阅者

```bash
╭─ ~/HelloROS2/ros2_ws main !1
╰─❯ ros2 run my_cpp_pkg smartphone
[INFO] [1791198435.035275452] [smartphone]: Smartphone has been started.
[INFO] [1791198559.344914548] [smartphone]: Hi,this is R2D2 from the robot news station.
[INFO] [1791198559.844857603] [smartphone]: Hi,this is R2D2 from the robot news station.
[INFO] [1791198560.344849852] [smartphone]: Hi,this is R2D2 from the robot news station.
[INFO] [1791198560.844860097] [smartphone]: Hi,this is R2D2 from the robot news station.
[INFO] [1791198561.344856369] [smartphone]: Hi,this is R2D2 from the robot news station.
[INFO] [1791198561.844829587] [smartphone]: Hi,this is R2D2 from the robot news station.
```

> 终止CPP发布者，运行Python发布者

```bash
#终止CPP发布者，消息订阅者停止接收信息
#然后启动Python发布者
╭─ ~/HelloROS2/ros2_ws main !1        6s
╰─❯ ros2 run my_py_pkg robot_news_station
[INFO] [1791198662.540373691] [py_test]: Robot News Station has been started.

#之后会查看到，消息订阅者继续接收信息
╭─ ~/HelloROS2/ros2_ws main !1
╰─❯ ros2 run my_cpp_pkg smartphone
[INFO] [1791198435.035275452] [smartphone]: Smartphone has been started.
[INFO] [1791198559.344914548] [smartphone]: Hi,this is R2D2 from the robot news station.
[INFO] [1791198559.844857603] [smartphone]: Hi,this is R2D2 from the robot news station.
[INFO] [1791198560.344849852] [smartphone]: Hi,this is R2D2 from the robot news station.
[INFO] [1791198560.844860097] [smartphone]: Hi,this is R2D2 from the robot news station.
[INFO] [1791198561.344856369] [smartphone]: Hi,this is R2D2 from the robot news station.
[INFO] [1791198561.844829587] [smartphone]: Hi,this is R2D2 from the robot news station.
#这之后的为Python发布者发布的
[INFO] [1791198663.003008073] [smartphone]: Hi, this is C3PO from the robot news station.
[INFO] [1791198663.502097830] [smartphone]: Hi, this is C3PO from the robot news station.
[INFO] [1791198664.002115561] [smartphone]: Hi, this is C3PO from the robot news station.
[INFO] [1791198664.502307105] [smartphone]: Hi, this is C3PO from the robot news station.
[INFO] [1791198665.002228570] [smartphone]: Hi, this is C3PO from the robot news station.
[INFO] [1791198665.502046632] [smartphone]: Hi, this is C3PO from the robot news station.
[INFO] [1791198666.002094318] [smartphone]: Hi, this is C3PO from the robot news station.

```

> 订阅者不知道也不关心消息来自谁，我们只是接收符合string数据类型且在robot_news话题上的消息

> 现在可以尝试任何Python、C++发布者的组合，配合任何Python、C++订阅者的组合



