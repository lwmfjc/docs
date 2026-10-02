---
title: "0302-"
description: "0302-"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-01T21:29:17+08:00
lastmod: 2026-10-01T21:29:17+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 创建一个ROS2工作空间

> 创建和设置一个ROS2工作空间

> 编写所有ROS2应用程序代码的地方，也是安装和编译这些代码的地方

```bash
╭─ ~/HelloROS2
╰─❯ mkdir ros2_ws

╭─ ~/HelloROS2
╰─❯ cd ros2_ws

╭─ ~/HelloROS2/ros2_ws #这个是ROS2工作空间
╰─❯ mkdir src

╭─ ~/HelloROS2/ros2_ws
╰─❯ tree
.
└── src #source目录，课程和应用程序创建的所有代码都位于src文件夹内

2 directories, 0 files
```

> 在工作目录下，可以执行`colcon build`

```bash
#如果该命令无效，确保使用了
#sudo apt install ros-dev-tools
╭─ ~/HelloROS2/ros2_ws
╰─❯ colcon build

Summary: 0 packages finished [0.77s]

#运行colcon build时自动生成了build install log 这三个文件夹
╭─ ~/HelloROS2/ros2_ws
╰─❯ dir
build  install  log  src

```

> 文件夹查看

```bash
╭─ ~/HelloROS2/ros2_ws
╰─❯ tree
.
├── build
│   └── COLCON_IGNORE
├── install
│   ├── COLCON_IGNORE
│   ├── local_setup.bash
│   ├── local_setup.ps1
│   ├── local_setup.sh
│   ├── _local_setup_util_ps1.py
│   ├── _local_setup_util_sh.py
│   ├── local_setup.zsh
│   ├── setup.bash
│   ├── setup.ps1
│   ├── setup.sh
│   └── setup.zsh
├── log
│   ├── build_2026-10-02_10-18-41
│   │   ├── events.log
│   │   └── logger_all.log
│   ├── COLCON_IGNORE
│   ├── latest -> latest_build
│   └── latest_build -> build_2026-10-02_10-18-41
└── src

8 directories, 15 files
```