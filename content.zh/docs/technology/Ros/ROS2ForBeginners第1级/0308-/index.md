---
title: "0308-"
description: "0308-"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-03T11:56:17+08:00
lastmod: 2026-10-03T11:56:17+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
回顾一下，前面学习了  

- 环境设置
- 启动第一个程序 
    - `ros2 run demo_nodes_cpp listener`
    - demo_nodes_cpp是自带的一个示例功能包，里面放了一些 C++ 示例程序
    - listener，是这个功能包里面的一个可执行程序名称
- 创建工作空间ros2_ws
- `ros2_ws/src`下创建包
    - `ros2 pkg create my_py_pkg --build-type ament_python --dependencies rclpy`
    - `ros2 pkg create my_cpp_pkg --build-type ament_cmake --dependencies rclcpp`
- Python包下
    - 创建节点文件`touch my_first_node.py`
    - 编写节点`node=Node("py_test")`
    - `setup.py`中的`console_scripts`下添加可执行文件`"py_node = my_py_pkg.my_first_node:main"`
    - 构建Python的功能包：`colcon build --packages-select my_py_pkg`
    - 运行可执行程序`ros2 run  my_py_pkg py_node`

# 创建一个CPP节点

```bash
#进入ROS2工作空间
╭─ ~
╰─❯ cd ~/HelloROS2/ros2_ws

#进入源文件目录的某个cpp包中
╭─ ~/HelloROS2/ros2_ws main
╰─❯ cd src/my_cpp_pkg

#进入该包的源文件夹中
╭─ ~/HelloROS2/ros2_ws/src/my_cpp_pkg main
╰─❯ cd src

╭─ ~/HelloROS2/ros2_ws/src/my_cpp_pkg/src main
╰─❯ ls

#创建源文件
╭─ ~/HelloROS2/ros2_ws/src/my_cpp_pkg/src main
╰─❯ touch my_first_node.cpp


╭─ ~/HelloROS2/ros2_ws/src/my_cpp_pkg/src main
╰─❯ code .
```

> 在VSCode扩展中，把这个拓展装上，这样写cpp代码时才会有自动补全

RoboticsDeveloperEnvironment ，作者 RanchHandRobotics LLC

> STM32Cube clangd 和 C/C++ 的智能提示会冲突，如果C/C++的只能提示没有反应，那么

- 打开 VSCode 设置（Ctrl+,），搜索 IntelliSense engine。
- 将 C_Cpp: IntelliSense Engine 的值从 Disabled 改回 Default。
- 检查并关闭 clangd 扩展，避免冲突。







