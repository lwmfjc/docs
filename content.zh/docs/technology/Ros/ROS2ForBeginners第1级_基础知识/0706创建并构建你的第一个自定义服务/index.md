---
title: "0706创建并构建你的第一个自定义服务"
description: "0706创建并构建你的第一个自定义服务"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-10T18:32:39+08:00
lastmod: 2026-10-10T18:32:39+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
> 构建服务定义

> 创建一个文件

```bash
╭─ ~/HelloROS2/ros2_ws/src/my_robot_interfaces main
╰─❯ ls
CMakeLists.txt  msg  package.xml

╭─ ~/HelloROS2/ros2_ws/src/my_robot_interfaces main
╰─❯ mkdir srv

╭─ ~/HelloROS2/ros2_ws/src/my_robot_interfaces main
╰─❯ cd srv

╭─ ~/HelloROS2/ros2_ws/src/my_robot_interfaces/srv main
╰─❯ touch ComputeRectangleArea.srv

╭─ ~/HelloROS2/ros2_ws/src/my_robot_interfaces/srv main ?1
╰─❯ ls
ComputeRectangleArea.srv


```

> 在vscode中编辑ComputeRectangleArea.srv

```srv
float64 length
float64 width
---
float64 area
```

> 修改CMakeLists.txt

```txt
# 用来生成接口的命令，我们要在里面写上所有创建的接口的路径
rosidl_generate_interfaces(
	${PROJECT_NAME}
	"msg/HardwareStatus.msg"  
	"srv/ComputeRectangleArea.srv" 
)
```

> 构建

```bash
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ colcon build --packages-select my_robot_interfaces
[1.232s] WARNING:colcon.colcon_core.package_selection:Some selected packages are already built in one or more underlay workspaces:
        'my_robot_interfaces' is in: /home/ly/HelloROS2/ros2_ws/install/my_robot_interfaces
If a package in a merged underlay workspace is overridden and it installs headers, then all packages in the overlay must sort their include directories by workspace order. Failure to do so may result in build failures or undefined behavior at run time.
If the overridden package is used by another package in any underlay, then the overriding package in the overlay must be API and ABI compatible or undefined behavior at run time may occur.

If you understand the risks and want to override a package anyways, add the following to the command line:
        --allow-overriding my_robot_interfaces

This may be promoted to an error in a future release of colcon-override-check.
Starting >>> my_robot_interfaces
Finished <<< my_robot_interfaces [18.3s]

Summary: 1 package finished [18.9s]
```

> 翻译 ：colcon override warning：当前工作空间中存在已经安装过的同名包，重新构建会覆盖旧版本。学习阶段通常删除 build/ install/ log/ 后重新构建即可

```bash
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ source install/setup.zsh

#查看服务接口
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 interface show my_robot_interfaces/srv/ComputeRectangleArea
float64 length
float64 width
---
float64 area
```