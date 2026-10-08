---
title: "0609使用ROS2命令行自检服务"
description: "0609使用ROS2命令行自检服务"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-08T21:04:00+08:00
lastmod: 2026-10-08T21:04:00+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
```bash
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 service
type  list  info  find  echo  call  -- None
```

```bash
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 service -h
usage: ros2 service [-h] [--include-hidden-services]
                    Call `ros2 service <command> -h` for more detailed usage. ...

Various service related sub-commands

options:
  -h, --help            show this help message and exit
  --include-hidden-services
                        Consider hidden services as well

Commands:
  call  Call a service
  echo  Echo a service
  find  Output a list of available services of a given type
  info  Print information about a service
  list  Output a list of available services
  type  Output a service's type

  Call `ros2 service <command> -h` for more detailed usage.

```

> 先启动一个服务

```bash
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 run my_cpp_pkg add_two_ints_server
[INFO] [1791466370.227873817] [add_two_ints_server]: Add Two Ints Service has been started.


```

