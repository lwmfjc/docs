---
title: "0707使用ROS2命令行自检接口"
description: "0707使用ROS2命令行自检接口"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-10T21:38:22+08:00
lastmod: 2026-10-10T21:38:22+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
> 本节使用ROS2命令行来检视我们已构建的接口

> 最重要事情，确保所有的终端都已经执行source

```bash
╭─ ~
╰─❯ ros2 interface show example_interfaces/msg/Int64
# This is an example message of using a primitive datatype, int64.
# If you want to test with this that's fine, but if you are deploying
# it into a system you should create a semantically meaningful message type.
# If you want to embed it in another message, use the primitive data type instead.
int64 data

╭─ ~
╰─❯ ros2 interface show my_robot_interfaces/srv/ComputeRectangleArea
float64 length
float64 width
---
float64 area
```

> `echo $AMENT_PREFIX_PATH` 是查看 ROS 2 当前环境搜索安装空间的路径列表。

```bash
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ echo $AMENT_PREFIX_PATH
/home/ly/HelloROS2/ros2_ws/install/my_py_pkg:/home/ly/HelloROS2/ros2_ws/install/my_cpp_pkg:/home/ly/HelloROS2/ros2_ws/install/my_robot_interfaces:/opt/ros/jazzy
```

```bash

#列出该环境中已安装并执行source的所有接口
#这里用grep过滤了一下
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 interface list | grep robot
    my_robot_interfaces/msg/HardwareStatus
    my_robot_interfaces/srv/ComputeRectangleArea

```

> 查看某个特定包的接口

```bash
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 interface package my_robot_interfaces
my_robot_interfaces/srv/ComputeRectangleArea
my_robot_interfaces/msg/HardwareStatus


#sensor_msgs包下的所有接口
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 interface package sensor_msgs
sensor_msgs/msg/MultiDOFJointState
sensor_msgs/msg/Imu
sensor_msgs/msg/LaserScan
sensor_msgs/msg/MagneticField
sensor_msgs/msg/NavSatStatus
sensor_msgs/msg/TimeReference
sensor_msgs/srv/SetCameraInfo
sensor_msgs/msg/Illuminance
sensor_msgs/msg/PointCloud2
sensor_msgs/msg/CompressedImage
sensor_msgs/msg/Temperature
sensor_msgs/msg/Joy
sensor_msgs/msg/Range
sensor_msgs/msg/PointCloud
sensor_msgs/msg/JoyFeedback
sensor_msgs/msg/JointState
sensor_msgs/msg/JoyFeedbackArray
sensor_msgs/msg/BatteryState
sensor_msgs/msg/LaserEcho
sensor_msgs/msg/ChannelFloat32
sensor_msgs/msg/PointField
sensor_msgs/msg/MultiEchoLaserScan
sensor_msgs/msg/RelativeHumidity
sensor_msgs/msg/CameraInfo
sensor_msgs/msg/NavSatFix
sensor_msgs/msg/RegionOfInterest
sensor_msgs/msg/Image
sensor_msgs/msg/FluidPressure

#查看某个接口定义
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 interface show sensor_msgs/msg/MagneticField
# Measurement of the Magnetic Field vector at a specific location.
#
# If the covariance of the measurement is known, it should be filled in.
# If all you know is the variance of each measurement, e.g. from the datasheet,
# just put those along the diagonal.
# A covariance matrix of all zeros will be interpreted as "covariance unknown",
# and to use the data a covariance will have to be assumed or gotten from some
# other source.

std_msgs/Header header               # timestamp is the time the
        builtin_interfaces/Time stamp
                int32 sec
                uint32 nanosec
        string frame_id
                                           # field was measured
                                           # frame_id is the location and orientation
                                           # of the field measurement

geometry_msgs/Vector3 magnetic_field # x, y, and z components of the
        float64 x
        float64 y
        float64 z
                                           # field vector in Tesla
                                           # If your sensor does not output 3 axes,
                                           # put NaNs in the components not reported.

float64[9] magnetic_field_covariance       # Row major about x, y, z axes
                                           # 0 is interpreted as variance unknown
```

> 假设有一个正在运行的接口

```bash
╭─ ~
╰─❯ ros2 run my_py_pkg hw_status_publisher
[INFO] [1791640244.241850521] [hardware_status_publisher]: Hw status publisher has been started.

```

> 信息查找

```bash
#先找到节点
#查询节点列表
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 node list
/hardware_status_publisher

#找到节点信息
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 node info /hardware_status_publisher
/hardware_status_publisher
  Subscribers:

  Publishers:
    #发布者
    /hardware_status: my_robot_interfaces/msg/HardwareStatus
    /parameter_events: rcl_interfaces/msg/ParameterEvent
    /rosout: rcl_interfaces/msg/Log
  Service Servers:
    /hardware_status_publisher/describe_parameters: rcl_interfaces/srv/DescribeParameters
    /hardware_status_publisher/get_parameter_types: rcl_interfaces/srv/GetParameterTypes
    /hardware_status_publisher/get_parameters: rcl_interfaces/srv/GetParameters
    /hardware_status_publisher/get_type_description: type_description_interfaces/srv/GetTypeDescription
    /hardware_status_publisher/list_parameters: rcl_interfaces/srv/ListParameters
    /hardware_status_publisher/set_parameters: rcl_interfaces/srv/SetParameters
    /hardware_status_publisher/set_parameters_atomically: rcl_interfaces/srv/SetParametersAtomically
  Service Clients:

  Action Servers:

  Action Clients:

#查找话题列表
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 topic list
/hardware_status
/parameter_events
/rosout

#话题信息
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 topic info /hardware_status
Type: my_robot_interfaces/msg/HardwareStatus
Publisher count: 1
Subscription count: 0


```

> 关闭刚才的发布者，启动一个service server

```bash
╭─ ~
╰─❯ ros2 run my_py_pkg add_two_ints_server
[INFO] [1791640450.128661589] [add_two_ints_server]: Add Two Ints server has been started.

╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 node list
/add_two_ints_server

╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 node info /add_two_ints_server
/add_two_ints_server
  Subscribers:

  Publishers:
    /parameter_events: rcl_interfaces/msg/ParameterEvent
    /rosout: rcl_interfaces/msg/Log
  Service Servers:
    #服务名称：接口
    /add_two_ints: example_interfaces/srv/AddTwoInts
    /add_two_ints_server/describe_parameters: rcl_interfaces/srv/DescribeParameters
    /add_two_ints_server/get_parameter_types: rcl_interfaces/srv/GetParameterTypes
    /add_two_ints_server/get_parameters: rcl_interfaces/srv/GetParameters
    /add_two_ints_server/get_type_description: type_description_interfaces/srv/GetTypeDescription
    /add_two_ints_server/list_parameters: rcl_interfaces/srv/ListParameters
    /add_two_ints_server/set_parameters: rcl_interfaces/srv/SetParameters
    /add_two_ints_server/set_parameters_atomically: rcl_interfaces/srv/SetParametersAtomically
  Service Clients:

  Action Servers:

  Action Clients:

```


```bash
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 service list                   
 /add_two_ints
/add_two_ints_server/describe_parameters
/add_two_ints_server/get_parameter_types
/add_two_ints_server/get_parameters
/add_two_ints_server/get_type_description
/add_two_ints_server/list_parameters
/add_two_ints_server/set_parameters
/add_two_ints_server/set_parameters_atomically

#查看服务使用的接口定义
╭─ ~/HelloROS2/ros2_ws main !1 ?1
╰─❯ ros2 service type /add_two_ints
example_interfaces/srv/AddTwoInts

```

> 【视频总结】主要是要区分，是通信层 ~~node,service,topic~~ \[他们传输的是某些消息（即接口）\]，还是通信的实际内容 ~~.srv,.msg~~ ，接口才是通过topic或者service发送的实际内容


【AI修改版】：

ROS2通信分两层：

1. 通信机制
   Node
   Topic
   Service
   Action

2. 通信数据定义（Interface）
   .msg
   .srv
   .action

```
Topic 使用 .msg
Service 使用 .srv
Action 使用 .action
```
