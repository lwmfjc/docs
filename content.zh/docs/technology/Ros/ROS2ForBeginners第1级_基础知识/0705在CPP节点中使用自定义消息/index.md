---
title: "0705在CPP节点中使用自定义消息"
description: "0705在CPP节点中使用自定义消息"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-10T18:25:04+08:00
lastmod: 2026-10-10T18:25:04+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 创建hardware_status_publisher.cpp

```bash
╭─ ~/HelloROS2/ros2_ws/src/my_cpp_pkg/src main !2 ?1
╰─❯ ls
add_two_ints_client.cpp         my_first_node.cpp       template_cpp_node.cpp
add_two_ints_client_no_oop.cpp  robot_news_station.cpp
add_two_ints_server.cpp         smartphone.cpp

╭─ ~/HelloROS2/ros2_ws/src/my_cpp_pkg/src main !2 ?1
╰─❯ touch hardware_status_publisher.cpp
```

```bash
#查看colcon构建的自定义消息的头文件地址
╭─ ~/HelloROS2/ros2_ws/src/my_cpp_pkg/src main !2 ?2
╰─❯ cd ~/HelloROS2/ros2_ws/install/my_robot_interfaces/

╭─ ~/HelloROS2/ros2_ws/install/my_robot_interfaces main !2 ?2
╰─❯ cd include

╭─ ~/HelloROS2/ros2_ws/install/my_robot_interfaces/include main !2 ?2
╰─❯ pwd
#我们需要这个路径
/home/ly/HelloROS2/ros2_ws/install/my_robot_interfaces/include

╭─ ~/HelloROS2/ros2_ws/install/my_robot_interfaces/include main !2 ?2
╰─❯ ls
my_robot_interfaces

╭─ ~/HelloROS2/ros2_ws/install/my_robot_interfaces/include main !2 ?2
╰─❯ ls my_robot_interfaces
my_robot_interfaces

╭─ ~/HelloROS2/ros2_ws/install/my_robot_interfaces/include main !2 ?2
╰─❯ cd my_robot_interfaces

╭─ ~/HelloROS2/r/install/my_robot_interfaces/include/my_robot_interfaces main !2 ?2
╰─❯ ls
my_robot_interfaces

╭─ ~/HelloROS2/r/install/my_robot_interfaces/include/my_robot_interfaces main !2 ?2
╰─❯ cd my_robot_interfaces

╭─ ~/HelloROS2/r/i/my_r/include/my_robot_interfaces/my_robot_interfaces main !2 ?2
╰─❯ ls
msg
 
╭─ ~/HelloROS2/r/i/my_r/include/my_robot_interfaces/my_robot_interfaces main !2 ?2
╰─❯ ls msg
detail
hardware_status.h
hardware_status.hpp
rosidl_generator_cpp__visibility_control.hpp
rosidl_generator_c__visibility_control.h
rosidl_typesupport_fastrtps_cpp__visibility_control.h
rosidl_typesupport_fastrtps_c__visibility_control.h
rosidl_typesupport_introspection_c__visibility_control.h


```

> 修改src目录下的vs配置文件 `.vscode/c_cpp_properties.json` ~~configurations下的includePath~~ 

> 这是为了让.cpp文件中#include "#include "my_robot_interfaces/msg" 有自动补全功能

```json
      "includePath": [
        "/opt/ros/jazzy/include/**",
        "/home/ly/HelloROS2/ros2_ws/src/my_cpp_pkg/include/**",
        "/usr/include/**",
        "/home/ly/HelloROS2/ros2_ws/install/my_robot_interfaces/include/**"
      ],
```

# 复制模板、添加头文件

```cpp
#include "rclcpp/rclcpp.hpp" 
//如果没有自动补全，需要修改.vscode里面的 c_cpp_properties.json
// includePath添加 工作区内的消息接口头文件夹路径
//注意 自定义的消息文件名单词之间用大写字母间隔的，这里变成了_下划线
#include "my_robot_interfaces/msg/hardware_status.hpp" 

class HardwareStatusPublisherNode : public rclcpp::Node
{

public:

    HardwareStatusPublisherNode() : Node("hardware_status_publisher")
    {
    }

private: 
};

int main(int argc, char **argv)
{
    
    rclcpp::init(argc, argv);
    auto node = std::make_shared<HardwareStatusPublisherNode>();//MODIFY NAME
    rclcpp::spin(node); 
    rclcpp::shutdown();
    return 0;
}
```

# 头文件#include解释

> 为什么这里includePath 添加的是 `"/home/ly/HelloROS2/ros2_ws/src/my_cpp_pkg/include/**"`，但是#include不是`#include "my_robot_interfaces/my_robot_interfaces/msg/` 呢

有两点
## 1. ROS2 的接口生成机制

**第一层 `my_robot_interfaces` 是安装布局（install prefix），第二层才是 C++ include 命名空间路径。**

这是 ROS2 的 install 结构：

```text
install/
└── my_robot_interfaces/
    └── include/
        └── my_robot_interfaces/
            └── my_robot_interfaces/
                └── msg/
```

第一层：

```text
install/my_robot_interfaces
```

是 **package 的安装目录**。

第二层：

```text
include/my_robot_interfaces
```

才是普通 include 根目录。

第三层：

```text
my_robot_interfaces/msg
```

才是实际 C++ include 路径。

所以真正的 includePath  ~~这里就不是说的.vscode/c_cpp_properties.json那个了。这是两码事~~  更应该指向：

```json
"/home/ly/HelloROS2/ros2_ws/install/my_robot_interfaces/include/my_robot_interfaces/**"
```

这样：

```cpp
#include "my_robot_interfaces/msg/hardware_status.hpp"
```

展开：

```
includePath
+
my_robot_interfaces/msg/hardware_status.hpp
```

得到：

```
install/my_robot_interfaces/include/my_robot_interfaces/
└── my_robot_interfaces
    └── msg
        └── hardware_status.hpp
```

### ①. 为什么 ROS2 推荐这种写法？

因为 ROS2 的接口包生成规则固定：

你的 `.msg`：

```
my_robot_interfaces/msg/HardwareStatus.msg
```

生成 C++ 后：

```cpp
#include "my_robot_interfaces/msg/hardware_status.hpp"
```

对应：

```
包名/
    msg/
        文件.hpp
```

也就是：

```
<package_name>/<interface_type>/<interface_name>.hpp
```

例如：

```cpp
#include "geometry_msgs/msg/twist.hpp"

#include "sensor_msgs/msg/laser_scan.hpp"

#include "my_robot_interfaces/msg/hardware_status.hpp"
```

这是 ROS2 的统一规范。

---

### ②. 你的 VSCode 配置建议

不要直接写：

```json
"/home/ly/HelloROS2/ros2_ws/install/my_robot_interfaces/include/**"
```

建议改成：

```json
"includePath": [
    "/opt/ros/jazzy/include/**",
    "/home/ly/HelloROS2/ros2_ws/src/my_cpp_pkg/include/**",
    "/home/ly/HelloROS2/ros2_ws/install/my_robot_interfaces/include/my_robot_interfaces/**",
    "/usr/include/**"
]
```

不过实际 ROS2 项目里更推荐：

```bash
compile_commands.json
```

让 VSCode 自动获取真实编译参数：

```bash
colcon build \
  --cmake-args \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

然后：

`.vscode/settings.json`

```json
{
    "C_Cpp.default.compileCommands":
    "${workspaceFolder}/build/compile_commands.json"
}
```

这样不用手动维护 includePath。

---

总结一句：

> `#include "my_robot_interfaces/msg/hardware_status.hpp"` 是 ROS2 接口的标准形式；你的 `includePath` 应该指向包含第一个 `my_robot_interfaces` 的目录，而不是它的上一级。你看到的双层 `my_robot_interfaces` 是 install 布局导致的，不代表 include 路径要写两层。

## 2.VSCode自动补全功能解释

> `**` 是 VSCode C/C++ 扩展对 `includePath` 的递归搜索通配符，它影响 **代码补全、跳转、错误检测** 等 IntelliSense 行为，但它不会改变 C++ 的 include 规则。


### ①. 普通路径和 `/**` 的区别

假设你的目录：

```
include/
└── my_robot_interfaces
    └── my_robot_interfaces
        └── msg
            └── hardware_status.hpp
```

---

#### 没有 `/**`

配置：

```json
"includePath": [
    "/home/ly/HelloROS2/ros2_ws/install/my_robot_interfaces/include"
]
```

VSCode 会认为：

> 这个目录就是 include 搜索根目录。

于是它尝试：

你写：

```cpp
#include "my_robot_interfaces/msg/hardware_status.hpp"
```

拼接：

```
include
+
my_robot_interfaces/msg/hardware_status.hpp
```

寻找：

```
include/
└── my_robot_interfaces
    └── msg
        └── hardware_status.hpp
```

但是你的真实文件：

```
include/
└── my_robot_interfaces
    └── my_robot_interfaces
        └── msg
            └── hardware_status.hpp
```

少了一层。

所以找不到。

---

#### 加上 `/**`

你的配置：

```json
"includePath": [
    "/home/ly/HelloROS2/ros2_ws/install/my_robot_interfaces/include/**"
]
```

意思类似：

> 从这个目录开始，下面所有子目录都加入搜索范围。

例如：

```
include/**
```

可以匹配：

```
include/
```

也可以匹配：

```
include/my_robot_interfaces
```

也可以匹配：

```
include/my_robot_interfaces/my_robot_interfaces
```

甚至：

```
include/a/b/c/d
```

---

所以 VSCode 扫描到：

```
include/my_robot_interfaces/my_robot_interfaces/msg/hardware_status.hpp
```

然后它知道：

存在一个头文件：

```
hardware_status.hpp
```

路径：

```
my_robot_interfaces/msg/hardware_status.hpp
```

于是补全：

```cpp
#include "my_robot_interfaces/msg/hardware_status.hpp"
```

---

### ②. 为什么不是补全成两层？

这是最容易误解的地方。

你可能认为：

> 文件在哪，就应该补全什么。

但是 VSCode 的 IntelliSense 不只是简单列目录。

它会分析头文件的**可包含路径**。

例如它发现：

```
A/
└── B/
    └── C.hpp
```

如果 A 是 include root：

那么：

```cpp
#include "B/C.hpp"
```

成立。

如果 B 是 include root：

那么：

```cpp
#include "C.hpp"
```

成立。

---

你的情况：

扫描范围：

```
include/**
```

里面发现：

```
include/
└── my_robot_interfaces/
    └── my_robot_interfaces/
        └── msg/
            └── hardware_status.hpp
```

它可以把：

```
my_robot_interfaces
```

里面的内容作为一个可能的 include root。

所以给出：

```
my_robot_interfaces/msg/hardware_status.hpp
```

---

### ③. 但是注意：`**` 不是 C++ 标准

比如：

```bash
g++ main.cpp \
-I/home/ly/HelloROS2/ros2_ws/install/my_robot_interfaces/include/**
```

这是错误理解。

gcc 不认识：

```
**
```

它只认识：

```
-I/path
```

例如：

正确：

```bash
g++ main.cpp \
-I/home/ly/HelloROS2/ros2_ws/install/my_robot_interfaces/include/my_robot_interfaces
```

然后：

```cpp
#include "my_robot_interfaces/msg/hardware_status.hpp"
```

寻找：

```
include/my_robot_interfaces/
└── my_robot_interfaces/msg/hardware_status.hpp
```

成功。

---

### ④. 为什么 ROS2 不推荐你手动这样配？

因为正常 ROS2 C++：

`CMakeLists.txt`

应该：

```cmake
find_package(my_robot_interfaces REQUIRED)

ament_target_dependencies(
    your_node
    my_robot_interfaces
)
```

然后 ament 自动生成：

```
-I/home/ly/HelloROS2/ros2_ws/install/my_robot_interfaces/include/my_robot_interfaces
```

所以真正编译器看到的是：

```
include root:
    install/my_robot_interfaces/include/my_robot_interfaces
```

而不是：

```
install/my_robot_interfaces/include/**
```

---

### ⑤. 你现在这个现象总结

你的：

```json
"includePath": [
    ".../include/**"
]
```

解决的是：

> VSCode 能不能找到头文件、能不能补全。

它比较“宽松”。

而 ROS2/CMake 解决的是：

> gcc 真正编译时从哪里找头文件。

它比较“严格”。

所以：

- VSCode 能补全 ✅
- `#include "my_robot_interfaces/msg/hardware_status.hpp"` 正确 ✅
- 不需要写双层目录 ✅

实际项目里，建议最终还是用 `compile_commands.json` 给 VSCode 提供真实编译参数，而不是依赖 `/**`。你现在这种配置适合学习阶段快速解决 IntelliSense 问题。

# package.xml添加依赖

```xml
<!--package标签下添加依赖-->

  <depend>my_robot_interfaces</depend>
```

# CMakeLists.txt中添加依赖

```cmake

#1添加下面这一行（添加依赖）
find_package(my_robot_interfaces REQUIRED)


```

# hardware_status_publisher.cpp完整代码

```cpp
#include "rclcpp/rclcpp.hpp"
// 如果没有自动补全，需要修改.vscode里面的 c_cpp_properties.json
//  includePath添加 工作区内的消息接口头文件夹路径
#include "my_robot_interfaces/msg/hardware_status.hpp"

using namespace std::chrono_literals;

class HardwareStatusPublisherNode : public rclcpp::Node
{

public:
    HardwareStatusPublisherNode() : Node("hardware_status_publisher")
    {
        pub_=this->create_publisher<my_robot_interfaces::msg::HardwareStatus>("hardware_status",10);
        timer_=this->create_wall_timer(
            1s,
            std::bind(&HardwareStatusPublisherNode::publishHardwareStatus,this)
        ); 
        RCLCPP_INFO(this->get_logger(),"Hardware status publisher has been started.");
    }

private:
    void publishHardwareStatus()
    {
        auto msg=my_robot_interfaces::msg::HardwareStatus();
        msg.temperature=57.2;
        msg.are_motors_ready=false;
        msg.debug_message="Motors are too hot!";
        pub_->publish(msg);
    }

    // 发布者
    rclcpp::Publisher<my_robot_interfaces::msg::HardwareStatus>::SharedPtr pub_;
    // 定时器
    rclcpp::TimerBase::SharedPtr timer_;
};

int main(int argc, char **argv)
{

    rclcpp::init(argc, argv);
    auto node = std::make_shared<HardwareStatusPublisherNode>(); // MODIFY NAME
    rclcpp::spin(node);
    rclcpp::shutdown();
    return 0;
}
```

# CMakeLists.txt添加新的可执行文件

```cmake

#1添加下面这2行
add_executable(hw_status_publisher src/hardware_status_publisher.cpp)
ament_target_dependencies(hw_status_publisher rclcpp my_robot_interfaces)

#安装
#将可执行文件安装到 lib/${PROJECT_NAME}
install(TARGETS
  cpp_node
  robot_news_station #再添加一个可执行文件
  smartphone
  add_two_ints_server
  add_two_ints_client_no_oop
  add_two_ints_client
  #3添加下面这一行
  hw_status_publisher
  DESTINATION lib/${PROJECT_NAME}
)
```

# 构建、加载、运行

```bash

#构建并安装功能包
╭─ ~/HelloROS2/ros2_ws main !4 ?2    
╰─❯ colcon build --packages-select my_cpp_pkg
Starting >>> my_cpp_pkg
Finished <<< my_cpp_pkg [22.4s]

Summary: 1 package finished [22.8s]

#加载构建后的环境
╭─ ~/HelloROS2/ros2_ws main !4 ?2    
╰─❯ source install/setup.zsh

#运行
╭─ ~/HelloROS2/ros2_ws main !4 ?2
╰─❯ ros2 run my_cpp_pkg hw_status_publisher
[INFO] [1791628023.493327346] [hardware_status_publisher]: Hardware status publisher has been started.
```

> 另一个终端

```bash
╭─ ~/HelloROS2/ros2_ws main !4 ?2
╰─❯ ros2 topic list
/hardware_status
/parameter_events
/rosout

╭─ ~/HelloROS2/ros2_ws main !4 ?2
╰─❯ ros2 topic info /hardware_status
Type: my_robot_interfaces/msg/HardwareStatus
Publisher count: 1 #有一个发布者正在发布
Subscription count: 0

#订阅消息
╭─ ~/HelloROS2/ros2_ws main !4 ?2
╰─❯ ros2 topic echo /hardware_status
temperature: 57.2
are_motors_ready: false
debug_message: Motors are too hot!
---
temperature: 57.2
are_motors_ready: false
debug_message: Motors are too hot!
---
temperature: 57.2
are_motors_ready: false
debug_message: Motors are too hot!
```