---
title: "0703创建并构建你的第一个自定义消息"
description: "0703创建并构建你的第一个自定义消息"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-09T21:48:51+08:00
lastmod: 2026-10-09T21:48:51+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
> 本节将学习如何创建第一个自定义的ROS2接口

```bash
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ls
build  install  log  src

╭─ ~/HelloROS2/ros2_ws main
╰─❯ cd src

╭─ ~/HelloROS2/ros2_ws/src main
╰─❯ ls
my_cpp_pkg  my_py_pkg
```

> 从技术上，可以把**消息定义**放在任意一个功能包中

> 但是建议，把**所有的自定义接口**，都创建在一个**专门**用于**存放自定义接口**的**独立功能包**里。可以避免在今后出现依赖混乱的问题。当你需要在另一个功能包里**导入自定义接口**时，比如从这个Python**功能包**，只需要给这个新的接口功能包添加依赖就可以

> 命名规范，应用名称_interfaces

# 创建包

```bash
╭─ ~/HelloROS2/ros2_ws/src main
╰─❯ ros2 pkg create my_robot_interfaces --build-type ament_cmake #即使不写--build-type ament_cmake 默认也是 ament_cmake
going to create a new package
package name: my_robot_interfaces
destination directory: /home/ly/HelloROS2/ros2_ws/src
package format: 3
version: 0.0.0
description: TODO: Package description
maintainer: ['ly <lwmfjc@gmail.com>']
licenses: ['TODO: License declaration']
build type: ament_cmake
dependencies: []
creating folder ./my_robot_interfaces
creating ./my_robot_interfaces/package.xml
creating source and include folder
creating folder ./my_robot_interfaces/src
creating folder ./my_robot_interfaces/include/my_robot_interfaces
creating ./my_robot_interfaces/CMakeLists.txt

[WARNING]: Unknown license 'TODO: License declaration'.  This has been set in the package.xml, but no LICENSE file has been created.
It is recommended to use one of the ament license identifiers:
Apache-2.0
BSL-1.0
BSD-2.0
BSD-2-Clause
BSD-3-Clause
GPL-3.0-only
LGPL-3.0-only
MIT
MIT-0
```

> 放自定义消息的功能包通常不分 Python / C++，而是专门的接口包（interface package）。

# 为什么创建接口包默认是 ament_cmake？ 

因为 ROS2 的**接口生成工具链主要基于 CMake**。

例如：

```
my_robot_interfaces
│
├── msg
│   └── RobotStatus.msg
│
├── srv
│   └── MoveRobot.srv
│
├── action
│   └── Navigate.action
│
├── package.xml
└── CMakeLists.txt
```

这里面没有：

```
my_robot_interfaces/
├── my_robot_interfaces/
│   └── xxx.py
```

也没有：

```
src/
└── xxx.cpp
```

因为它不是运行节点。

------

# 包文件

```bash
╭─ ~/HelloROS2/ros2_ws/src/my_robot_interfaces main ?1
╰─❯ ls
CMakeLists.txt  include  package.xml  src
```

> CMakeLists.txt 用来编写构建接口的规则

```bash
╭─ ~/HelloROS2/ros2_ws/src/my_robot_interfaces main ?1
╰─❯ ls
CMakeLists.txt  include  package.xml  src

#清理不需要的文件夹：include、src
╭─ ~/HelloROS2/ros2_ws/src/my_robot_interfaces main ?1
╰─❯ rm -rf include src

╭─ ~/HelloROS2/ros2_ws/src/my_robot_interfaces main ?1
╰─❯ ls
CMakeLists.txt  package.xml
```

> 为了构建接口，需要修改一些文件
> 参考网址 https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Custom-ROS2-Interfaces.html  

## 修改 package.xml


```xml
<!--需要在 <package> 元素下添加 --> 

<!--这2个要放在test_depend标签之前-->
<!--需要的构建工具依赖-->
<buildtool_depend>rosidl_default_generators</buildtool_depend> 
<!--需要的运行时依赖-->
<exec_depend>rosidl_default_runtime</exec_depend>

<!--这个要放在test_depend标签之后-->
<!--包 `tutorial_interfaces` 应该加入这个组中，即告诉ros2这个包是一个接口包-->
<member_of_group>rosidl_interface_packages</member_of_group>
```


翻译：

因为这些 **接口（interfaces）** 依赖 `rosidl_default_generators` 来生成不同编程语言对应的代码，所以你需要声明一个**构建工具依赖（build tool dependency）**。

`rosidl_default_runtime` 是一个**运行时依赖（runtime / execution-stage dependency）**，当之后使用这些接口时，需要它来支持接口的运行。

`rosidl_interface_packages` 是一个**依赖组（dependency group）**的名称，你的包 `tutorial_interfaces` 应该加入这个组中。加入方式是使用 `<member_of_group>` 标签声明。

在 `package.xml` 文件的 `<package>` 元素内部添加下面这些内容：

```xml
<!--这里不需要-->
<!--<depend>geometry_msgs</depend>-->

<buildtool_depend>rosidl_default_generators</buildtool_depend>

<exec_depend>rosidl_default_runtime</exec_depend>

<member_of_group>rosidl_interface_packages</member_of_group>
```

---

逐个解释：

### 1. `<depend>geometry_msgs</depend>`

表示你的接口依赖 `geometry_msgs`。

例如你定义一个消息：

```
# MyRobot.msg

geometry_msgs/Point position
float64 speed
```

这里用了：

```
geometry_msgs/Point
```

所以需要声明依赖。

---

### 2. `<buildtool_depend>rosidl_default_generators</buildtool_depend>`

表示：

> 构建这个接口包时，需要 `rosidl_default_generators`

为什么？

因为你写的：

```
MyRobot.msg
```

ROS2 不能直接使用。

构建时需要生成：

Python代码：

```
my_robot_interfaces/msg/_my_robot.py
```

C++代码：

```
my_robot_interfaces/msg/detail/my_robot__struct.hpp
```

这些生成工作由：

```
rosidl_default_generators
```

负责。

所以它属于：

```
buildtool_depend
```

即：

> 编译/构建阶段需要。

---

### 3. `<exec_depend>rosidl_default_runtime</exec_depend>`

表示：

运行你的程序时，需要：

```
rosidl_default_runtime
```

例如：

你的节点：

```python
from my_robot_interfaces.msg import MyRobot
```

运行时需要 ROS2 找到这个接口生成的代码。

所以：

```
rosidl_default_runtime
```

属于：

> 执行阶段依赖。

---

### 4. `<member_of_group>rosidl_interface_packages</member_of_group>`

表示：

告诉 ROS2：

> 这个包是一个接口包。

也就是：

```
tutorial_interfaces
```

不是普通功能包：

```
my_robot_controller
```

而是专门定义：

```
.msg
.srv
.action
```

的包。

例如：

```
my_robot_interfaces
├── msg
│   └── RobotStatus.msg
├── srv
│   └── ResetRobot.srv
└── action
    └── MoveRobot.action
```

这种包都应该加入：

```
rosidl_interface_packages
```

组。

---

整体关系可以理解为：

```
你写接口文件
        |
        v
 MyRobot.msg
        |
        |
        v
rosidl_default_generators
(构建时生成代码)
        |
        v
 C++ / Python接口代码
        |
        |
        v
rosidl_default_runtime
(运行节点时使用)
```

所以一个 ROS2 自定义接口包通常有：

```xml
<buildtool_depend>rosidl_default_generators</buildtool_depend>
<exec_depend>rosidl_default_runtime</exec_depend>
<member_of_group>rosidl_interface_packages</member_of_group>
```

这是标准模板。你现在学习的 `my_robot_interfaces` 就属于这种类型。

## 修改CMakeLists.txt

> 删除构建测试相关的功能

```cmake
# find_package之后添加
#这里不需要
#find_package(geometry_msgs REQUIRED)
find_package(rosidl_default_generators REQUIRED)

#用来生成接口的命令，我们要在里面写上所有创建的接口的路径
rosidl_generate_interfaces(${PROJECT_NAME}
  "msg/Num.msg"
  "msg/Sphere.msg"
  "srv/AddThreeInts.srv"
  #DEPENDENCIES geometry_msgs # Add packages that above messages depend on, in this case geometry_msgs for Sphere.msg #添加上面定义的消息所依赖的软件包。在这个例子中，Sphere.msg 依赖 geometry_msgs
)

#导出接口包的运行时依赖，让其他依赖该接口包的 ROS2 包自动获得 rosidl_default_runtime 依赖。
#这里其实是跟 package.xml中的 <exec_depend>rosidl_default_runtime</exec_depend> 相对应
ament_export_dependencies(rosidl_default_runtime)
```

# 专有名词称呼

在 ROS 2 里，.msg 和 .srv 统称为**接口定义文件（Interface definition files）**，简称 **接口文件（interfaces）**。
层级关系可以这样记：

```bash
接口（Interface）
│
├── Message interface（消息接口）
│   └── .msg 文件
│
├── Service interface（服务接口）
│   └── .srv 文件
│
└── Action interface（动作接口）
    └── .action 文件
```

所以：

| 文件                 | 正确称呼                    | 作用                               |
| ------------------ | ----------------------- | -------------------------------- |
| `Num.msg`          | 消息接口（Message interface） | 定义 Topic 传输的数据结构                 |
| `Sphere.msg`       | 消息接口                    | 定义消息字段                           |
| `AddThreeInts.srv` | 服务接口（Service interface） | 定义 Service 的请求和响应结构              |
| `xxx.action`       | 动作接口（Action interface）  | 定义 Action 的 Goal、Feedback、Result |

# 创建第一个接口（消息接口）

## 添加 msg/HardwareStatus.msg

```bash
╭─ ~/HelloROS2/ros2_ws/src/my_robot_interfaces main ?1
╰─❯ ls
CMakeLists.txt  package.xml

╭─ ~/HelloROS2/ros2_ws/src/my_robot_interfaces main ?1
╰─❯ mkdir msg

╭─ ~/HelloROS2/ros2_ws/src/my_robot_interfaces main ?1
╰─❯ cd msg

```

> 假设要发布机器人的硬件状态，里面会包含机器人的一些信息，比如名称、版本号、温度等

```bash
╭─ ~/HelloROS2/ros2_ws/src/my_robot_interfaces/msg main ?1
╰─❯ touch HardwareStatus.msg #注意，文件名不能用下划线_也不能用短斜杠-，每个单词都以大写字母开头。.msg表示消息定义

```

> 编辑HardwareStatus.msg

> 可以使用基本数据类型，也可以使用这个功能包或者其他功能包里已有的消息

> 单词之间用下划线分割，不能用其他符号

```msg
float64 temperature
bool are_motors_ready
string debug_message
```

## 修改CMakeLists.txt

> 修改rosidl_generate_interfaces

```cmake
# 用来生成接口的命令，我们要在里面写上所有创建的接口的路径
rosidl_generate_interfaces(
	${PROJECT_NAME}
	"msg/HardwareStatus.msg" 
)
```

## colcon build

```bash
╭─ ~/HelloROS2/ros2_ws/src/my_robot_interfaces/msg main ?1
╰─❯ cd ~/HelloROS2/ros2_ws

#构建接口
╭─ ~/HelloROS2/ros2_ws main ?1
╰─❯ colcon build --packages-select my_robot_interfaces
Starting >>> my_robot_interfaces
Finished <<< my_robot_interfaces [23.2s]

Summary: 1 package finished [23.7s]
```

> 简单解释下install文件夹下生成的文件

colcon build 后：

```bash
install/
└── my_robot_interfaces

include/
→ C/C++接口头文件
→ C++节点 #include 使用

lib/python3.x/site-packages/
→ Python接口包
→ Python节点 import 使用

lib/*.so
→ ROS 2 类型支持库
→ DDS通信、中间转换使用

share/
→ ROS 2包的描述信息、CMake配置、接口定义文件
```

> 重新加载构建后的环境

```bash
╭─ ~/HelloROS2/ros2_ws main ?1
╰─❯ ls
build  install  log  src

╭─ ~/HelloROS2/ros2_ws main ?1
╰─❯ source install/setup.zsh

```

> 查看接口定义

```bash
╭─ ~/HelloROS2/ros2_ws main ?1
╰─❯ ros2 interface show my_robot_interfaces/msg/HardwareStatus
float64 temperature
bool are_motors_ready
string debug_message
```




