---
title: "0402-0404ROS2命令、运行时重命名、colcon"
description: "0402-0404ROS2命令、运行时重命名、colcon"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-04T10:57:31+08:00
lastmod: 2026-10-04T10:57:31+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
> 对于Python和C++，安装节点后，会在ROS2工作区的install文件夹中获得一个可执行文件 ~~都是在 `包名文件夹/lib/包名文件夹/` 下~~ 

```bash
╭─ ~/HelloROS2 main
╰─❯ tree install
install
├── COLCON_IGNORE
├── local_setup.bash
├── local_setup.ps1
├── local_setup.sh
├── _local_setup_util_ps1.py
├── _local_setup_util_sh.py
├── local_setup.zsh
├── my_cpp_pkg
│   ├── lib
│   │   └── my_cpp_pkg
│   │       └── cpp_node #这个，可执行文件
│   └── share
│       ├── ament_index
│       │   └── resource_index
│       │       ├── package_run_dependencies
│       │       │   └── my_cpp_pkg
│       │       ├── packages
│       │       │   └── my_cpp_pkg
│       │       └── parent_prefix_path
│       │           └── my_cpp_pkg
│       ├── colcon-core
│       │   └── packages
│       │       └── my_cpp_pkg
│       └── my_cpp_pkg
│           ├── cmake
│           │   ├── my_cpp_pkgConfig.cmake
│           │   └── my_cpp_pkgConfig-version.cmake
│           ├── environment
│           │   ├── ament_prefix_path.dsv
│           │   ├── ament_prefix_path.sh
│           │   ├── path.dsv
│           │   └── path.sh
│           ├── hook
│           │   ├── cmake_prefix_path.dsv
│           │   ├── cmake_prefix_path.ps1
│           │   └── cmake_prefix_path.sh
│           ├── local_setup.bash
│           ├── local_setup.dsv
│           ├── local_setup.sh
│           ├── local_setup.zsh
│           ├── package.bash
│           ├── package.dsv
│           ├── package.ps1
│           ├── package.sh
│           ├── package.xml
│           └── package.zsh
├── my_py_pkg
│   ├── lib
│   │   ├── my_py_pkg
│   │   │   └── py_node  #这个，可执行文件
│   │   └── python3.12
│   │       └── site-packages
│   │           ├── my_py_pkg
│   │           │   ├── __init__.py
│   │           │   ├── my_first_node.py
│   │           │   └── __pycache__
│   │           │       ├── __init__.cpython-312.pyc
│   │           │       └── my_first_node.cpython-312.pyc
│   │           └── my_py_pkg-0.0.0-py3.12.egg-info
│   │               ├── dependency_links.txt
│   │               ├── entry_points.txt
│   │               ├── PKG-INFO
│   │               ├── requires.txt
│   │               ├── SOURCES.txt
│   │               ├── top_level.txt
│   │               └── zip-safe
│   └── share
│       ├── ament_index
│       │   └── resource_index
│       │       └── packages
│       │           └── my_py_pkg
│       ├── colcon-core
│       │   └── packages
│       │       └── my_py_pkg
│       └── my_py_pkg
│           ├── hook
│           │   ├── ament_prefix_path.dsv
│           │   ├── ament_prefix_path.ps1
│           │   ├── ament_prefix_path.sh
│           │   ├── pythonpath.dsv
│           │   ├── pythonpath.ps1
│           │   └── pythonpath.sh
│           ├── package.bash
│           ├── package.dsv
│           ├── package.ps1
│           ├── package.sh
│           ├── package.xml
│           └── package.zsh
├── setup.bash
├── setup.ps1
├── setup.sh
└── setup.zsh

32 directories, 61 files
```

# ros2命令行工具

> ros2命令后可用的参数

```bash
╭─ ~
╰─❯ ros2 [tab]
component         action     bag
extension_points  doctor     daemon
extensions        interface  launch
multicast         lifecycle  node
plugin            param      pkg
security          service    run
topic             wtf                -- None
```


```bash
#启动节点
#ros2 run 包名 可执行文件名
#这个一个在全局ROS2安装中安装的节点
╭─ ~
╰─❯ ros2 run demo_nodes_cpp talker
[INFO] [1791084770.717892753] [talker]: Publishing: 'Hello World: 1'
[INFO] [1791084771.717760576] [talker]: Publishing: 'Hello World: 2'
[INFO] [1791084772.717848402] [talker]: Publishing: 'Hello World: 3'
[INFO] [1791084773.718228808] [talker]: Publishing: 'Hello World: 4'
^C[INFO] [1791084774.545797326] [rclcpp]: signal_handler(SIGINT/SIGTERM)


```

```bash
#ros2 run 之后tab会自动补全包名/可执行文件名
╭─ ~
╰─❯ ros2 run my_py_pkg py_node
```

```bash
╭─ ~       
╰─❯ ros2 run my_cpp_pkg cpp_node
[INFO] [1791084916.899326440] [cpp_test]: Hello world
[INFO] [1791084917.899936122] [cpp_test]: Hello 0
[INFO] [1791084919.765764689] [cpp_test]: Hello 1
[INFO] [1791084920.765998665] [cpp_test]: Hello 2
[INFO] [1791084921.765753316] [cpp_test]: Hello 3
^C[INFO] [1791084922.272478595] [rclcpp]: signal_handler(SIGINT/SIGTERM)
```

> 现在将.zshrc中的 `source ~/HelloROS2/ros2_ws/install/setup.zsh` 注释

```bash
#新开一个终端
#提示包没有找到
╭─ ~/HelloROS2 main
╰─❯ ros2 run my_py_pkg py_node
Package 'my_py_pkg' not found
```

> 现在取消.zshrc中对 `source ~/HelloROS2/ros2_ws/install/setup.zsh` 注释

> 打开四个终端 
> alt+shift+- 水平分割
> alt+shift++ 垂直分割

```bash
#查看帮助
╭─ ~/HelloROS2 main
╰─❯ ros2 run -h
usage: ros2 run [-h] [--prefix PREFIX]
                package_name
                executable_name ...

Run a package specific executable

positional arguments:
  package_name     Name of the ROS
                   package
  executable_name  Name of the
                   executable
  argv             Pass arbitrary
                   arguments to the
                   executable

options:
  -h, --help       show this help
                   message and exit
  --prefix PREFIX  Prefix command,
                   which should go
                   before the
                   executable. Command
                   must be wrapped in
                   quotes if it
                   contains spaces
                   (e.g. --prefix 'gdb
                   -ex run --args').


```

```bash
#运行节点
╭─ ~/HelloROS2 main
╰─❯ ros2 run my_py_pkg py_node
[INFO] [1791085673.486295864] [py_test]: Hello world
[INFO] [1791085674.489914717] [py_test]: Hello0
[INFO] [1791085675.489835042] [py_test]: Hello1
[INFO] [1791085676.490068487] [py_test]: Hello2
[INFO] [1791085677.489001061] [py_test]: Hello3

#内省查看当前运行的节点
╭─ ~/HelloROS2 main
╰─❯ ros2 node  list
/py_test


╭─ ~/HelloROS2 main
╰─❯ ros2 run my_cpp_pkg cpp_node
[INFO] [1791085768.294217836] [cpp_test]: Hello world
[INFO] [1791085769.297734322] [cpp_test]: Hello 0
[INFO] [1791085770.297803946] [cpp_test]: Hello 1
[INFO] [1791085771.298059133] [cpp_test]: Hello 2
[INFO] [1791085772.297700860] [cpp_test]: Hello 3
[INFO] [1791085773.297757249] [cpp_test]: Hello 4 


╭─ ~/HelloROS2 main
╰─❯ ros2 node  list
/cpp_test
/py_test

#查看节点信息
#info后以斜杠开头
╭─ ~/HelloROS2 main
╰─❯ ros2 node info /cpp_test
/cpp_test
  Subscribers: #订阅者
    /parameter_events: rcl_interfaces/msg/ParameterEvent
  Publishers: #发布者
    /parameter_events: rcl_interfaces/msg/ParameterEvent
    /rosout: rcl_interfaces/msg/Log
  Service Servers: #服务服务器
    /cpp_test/describe_parameters: rcl_interfaces/srv/DescribeParameters
    /cpp_test/get_parameter_types: rcl_interfaces/srv/GetParameterTypes
    /cpp_test/get_parameters: rcl_interfaces/srv/GetParameters
    /cpp_test/get_type_description: type_description_interfaces/srv/GetTypeDescription
    /cpp_test/list_parameters: rcl_interfaces/srv/ListParameters
    /cpp_test/set_parameters: rcl_interfaces/srv/SetParameters
    /cpp_test/set_parameters_atomically: rcl_interfaces/srv/SetParametersAtomically
  Service Clients:

  Action Servers:

  Action Clients:



```

> alt+shift+z ：放大其中一个终端


```bash
#-h查看帮助
╭─ ~/HelloROS2 main
╰─❯ ros2 node -h
usage: ros2 node [-h] Call `ros2 node <command> -h` for more detailed usage. ...

Various node related sub-commands

options:
  -h, --help            show this help message and exit

Commands:
  info  Output information about a node
  list  Output a list of available nodes

  Call `ros2 node <command> -h` for more detailed usage.
```

> 启动节点时要注意的，不能有两个名称相同的节点。执行`ros2 node list`时不该有两个名称相同的节点

# 运行时重命名节点

> 场景：比如有一个温度传感器的节点，并且有五个温度传感器，那么将希望启动同一个节点五次 ~~但是每个传感器要有不同的名称~~ 

```bash
#终端1
╭─ ~/HelloROS2 main
╰─❯ ros2 run my_py_pkg py_node
[INFO] [1791087157.708421747] [py_test]: Hello world
[INFO] [1791087158.710783274] [py_test]: Hello0
[INFO] [1791087159.710685608] [py_test]: Hello1
[INFO] [1791087160.711421686] [py_test]: Hello2
[INFO] [1791087161.714565522] [py_test]: Hello3
[INFO] [1791087162.712661274] [py_test]: Hello4

#终端2
─ ~/HelloROS2 main
╰─❯ ros2 run my_py_pkg py_node
[INFO] [1791087170.275234123] [py_test]: Hello world
[INFO] [1791087171.278599614] [py_test]: Hello0
[INFO] [1791087172.278736764] [py_test]: Hello1
[INFO] [1791087173.278480494] [py_test]: Hello2
[INFO] [1791087174.278070504] [py_test]: Hello3

#终端3
╭─ ~/HelloROS2 main
╰─❯ ros2 node list

#警告，可能会产生意外的错误
WARNING: Be aware that there are nodes in the graph that share an exact name, which can have unintended side effects.
/py_test
/py_test

```

> 解决问题：启动ros节点时重命名节点

```bash
#重命名为abc启动节点
╭─ ~/HelloROS2 main
╰─❯ ros2 run my_py_pkg py_node --ros-args -r __node:=abc
#或者 ros2 run my_py_pkg py_node --ros-args --remap __node:=abc
[INFO] [1791087477.155908280] [abc]: Hello world
[INFO] [1791087478.164849489] [abc]: Hello0
[INFO] [1791087479.157548306] [abc]: Hello1
[INFO] [1791087480.157936336] [abc]: Hello2
[INFO] [1791087481.160713385] [abc]: Hello3 

#正常启动节点
╭─ ~/HelloROS2 main
╰─❯ ros2 run my_py_pkg py_node
[INFO] [1791087495.207364287] [py_test]: Hello world
[INFO] [1791087496.213173676] [py_test]: Hello0
[INFO] [1791087497.210111522] [py_test]: Hello1
[INFO] [1791087498.208774765] [py_test]: Hello2
[INFO] [1791087499.209403112] [py_test]: Hello3

#没有警告了
╭─ ~/HelloROS2 main
╰─❯ ros2 node list
/abc
/py_test

```

> 本课程中，经常会使用 `ros-args`以及在其后添加所有参数，因此还可以重命名通信（主题、服务等）。还可以添加参数

```bash
ros2 run my_py_pkg py_node --ros-args -r __node:=abc
```

# colcon

> colcon 的音标：`/ˈkɒlkɒn/`（英式）

> 只能在工作区根目录下 ~~这里是ros2_ws目录~~ 使用colcon构建

```bash
#构建source文件夹下所有的包
╭─ ~/HelloROS2/ros2_ws main
╰─❯ colcon build
Starting >>> my_cpp_pkg
Starting >>> my_py_pkg
Finished <<< my_py_pkg [4.74s]
Finished <<< my_cpp_pkg [12.5s]

Summary: 2 packages finished [13.1s]
```

> --packages-select 指定某些

```bash
╭─ ~/HelloROS2/ros2_ws main
╰─❯ colcon build --packages-select my_cpp_pkg my_py_pkg
Starting >>> my_cpp_pkg
Starting >>> my_py_pkg
Finished <<< my_cpp_pkg [1.06s]
Finished <<< my_py_pkg [4.23s]

Summary: 2 packages finished [4.92s]

```

> 1. 如果要使用 --symlink-install，要确保 my_first_node.py 这个文件有可执行权限，即`chmod +x my_first_node.py`  ~~但是我试了下没给他可执行权限也行~~ 
> 2.  当使用--simlink-install构建了包，当执行ros2 run时，将执行运行在工作区source文件夹中编写的文件，而不是install 文件夹中的文件；仅适用于包含Python节点的Python包

```bash
╭─ ~/HelloROS2/ros2_ws main
╰─❯ colcon build --packages-select my_py_pkg --symlink-install
Starting >>> my_py_pkg
Finished <<< my_py_pkg [5.87s]

Summary: 1 package finished [6.24s]

#第一次使用 --symlink-install构建后需要source
╭─ ~/HelloROS2/ros2_ws main !1   
╰─❯ source install/setup.zsh

╭─ ~/HelloROS2/ros2_ws main !1
╰─❯ ros2 run my_py_pkg py_node
[INFO] [1791098512.912009466] [py_test]: Hello world
[INFO] [1791098513.914394666] [py_test]: Hello0

```

> 好处是这样就可以直接编辑Python文件并直接启动他们，无需重新构建工作区；有时候可能会有一些问题，所以不太建议使用

此时修改 `my_py_pkg/my_py_pkg/my_first_node.py` 中 `self.get_logger().info("Hello world--symlink-install")`

```bash
#直接ros2 run；不需要重新构建以及source加载构建后的环境
╭─ ~/HelloROS2/ros2_ws main !1     
╰─❯ ros2 run my_py_pkg py_node
[INFO] [1791098662.384185666] [py_test]: Hello world--symlink-install
[INFO] [1791098663.387441017] [py_test]: Hello0
[INFO] [1791098664.387186601] [py_test]: Hello1
```

> 使用Python编程时，第一次构建时使用 --symlink-install 对于快速迭代功能非常有用 ~~对CPP没效果~~ ；仅适用于开发阶段，生产化的模式下不建议这么用