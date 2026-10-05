---
title: "0503-"
description: "0503-"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-04T17:38:19+08:00
lastmod: 2026-10-04T17:38:19+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 编写一个Python发布者

> 创建一个节点，在节点中添加一个发布者，将以每秒两次的频率在某个主题发布一些文本

> 这里用之前的my_py_pkg中的包，在里面创建一个节点  

```bash
╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg main
╰─❯ ls
__init__.py  my_first_node_dian_py.bak  my_first_node.py  __pycache__

#在包的同名文件夹下，创建一个Python文件
#想象这是一个新闻站，将在一个主题上发布一些文本
╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg main
╰─❯ touch robot_news_station.py

#这是为了如果使用--symlink-install时，必须让文件拥有可执行权限
#我注释了是因为我发现没有可执行权限也是可以的
╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg main ?1
╰─❯ #chmod +x robot_news_station.py

╭─ ~/HelloROS2/ros2_ws/src/my_py_pkg/my_py_pkg main ?1                         ✘ INT
╰─❯ cd ../..

#从src这个文件夹打开vscode
╭─ ~/HelloROS2/ros2_ws/src main ?1
╰─❯ code .

```

> 这里还有一个要点，就是视频作者这里创建了一个模版 ~~知识都是原来那些~~ ，文件名 `template_python_node.py`

```python
#!/usr/bin/env python3
import rclpy 
from rclpy.node import Node

class MyCustomNode(Node): #MODIFY NAME
    def __init__(self):
        super().__init__("py_test")  #MODIFY NAME
        
def main(args=None):
    rclpy.init(args=args) 
    node=MyCustomNode()  #MODIFY NAME
    rclpy.spin(node)
    rclpy.shutdown()

if __name__ == "__main__":
    main()

```

复制`template_python_node.py`内容并粘贴进`robot_news_station.py` 并修改。  

```bash
#用来显示且已安装的接口
╭─ ~/HelloROS2/ros2_ws main !1 ?2
╰─❯ ros2 interface show example_interfaces/msg/String
# This is an example message of using a primitive datatype, string.
# If you want to test with this that's fine, but if you are deploying
# it into a system you should create a semantically meaningful message type.
# If you want to embed it in another message, use the primitive data type instead.
string data #我们有一个data的字段，类型为string
```

```bash
#这个share目录下有一堆包，如果需要使用的话，除了from xx import yyy ，还
#要在packages.xml中添加<depend>zzzz</depend>
╭─ ∅ /opt/ros/jazzy/share
╰─❯ ls
actionlib_msgs                          rclcpp_action
action_msgs                             rclcpp_components
action_tutorials_cpp                    rclcpp_lifecycle
action_tutorials_interfaces             rcl_interfaces
action_tutorials_py                     rcl_lifecycle
actuator_msgs                           rcl_logging_interface
ament_cmake                             rcl_logging_spdlog
ament_cmake_auto                        rclpy
ament_cmake_copyright                   rcl_yaml_param_parser
ament_cmake_core                        rcpputils
ament_cmake_cppcheck                    rcutils
ament_cmake_cpplint                     resource_retriever
ament_cmake_export_definitions          rmw
ament_cmake_export_dependencies         rmw_dds_common
ament_cmake_export_include_directories  rmw_fastrtps_cpp
ament_cmake_export_interfaces           rmw_fastrtps_shared_cpp
ament_cmake_export_libraries            rmw_implementation
ament_cmake_export_link_flags           rmw_implementation_cmake
ament_cmake_export_targets              robot_state_publisher
ament_cmake_flake8                      ros2action
ament_cmake_gen_version_h               ros2bag
ament_cmake_gmock                       ros2cli
ament_cmake_gtest                       ros2cli_common_extensions
ament_cmake_include_directories         ros2component
ament_cmake_libraries                   ros2doctor
ament_cmake_lint_cmake                  ros2interface
ament_cmake_pep257                      ros2launch
ament_cmake_pytest                      ros2lifecycle
ament_cmake_python                      ros2multicast
ament_cmake_ros                         ros2node
ament_cmake_target_dependencies         ros2param
ament_cmake_test                        ros2pkg
ament_cmake_uncrustify                  ros2plugin
ament_cmake_version                     ros2run
ament_cmake_xmllint                     ros2service
ament_copyright                         ros2topic
ament_cppcheck                          rosbag2
ament_cpplint                           rosbag2_compression
ament_flake8                            rosbag2_compression_zstd
ament_index                             rosbag2_cpp
ament_index_cpp                         rosbag2_interfaces
ament_index_python                      rosbag2_py
ament_lint                              rosbag2_storage
ament_lint_auto                         rosbag2_storage_default_plugins
ament_lint_cmake                        rosbag2_storage_mcap
ament_lint_common                       rosbag2_storage_sqlite3
ament_package                           rosbag2_transport
ament_pep257                            ros_base
ament_uncrustify                        ros_core
ament_xmllint                           ros_environment
angles                                  rosgraph_msgs
bond                                    ros_gz
bondcpp                                 ros_gz_bridge
builtin_interfaces                      ros_gz_image
class_loader                            ros_gz_interfaces
common_interfaces                       ros_gz_sim
composition                             ros_gz_sim_demos
composition_interfaces                  rosidl_adapter
compressed_depth_image_transport        rosidl_cli
compressed_image_transport              rosidl_cmake
console_bridge_vendor                   rosidl_core_generators
cv_bridge                               rosidl_core_runtime
demo_nodes_cpp                          rosidl_default_generators
demo_nodes_cpp_native                   rosidl_default_runtime
demo_nodes_py                           rosidl_dynamic_typesupport
depthimage_to_laserscan                 rosidl_dynamic_typesupport_fastrtps
desktop                                 rosidl_generator_c
diagnostic_msgs                         rosidl_generator_cpp
domain_coordinator                      rosidl_generator_py
dummy_map_server                        rosidl_generator_rs
dummy_robot_bringup                     rosidl_generator_type_description
dummy_sensors                           rosidl_parser
eigen3_cmake_module                     rosidl_pycommon
example_interfaces                      rosidl_runtime_c
examples_rclcpp_minimal_action_client   rosidl_runtime_cpp
examples_rclcpp_minimal_action_server   rosidl_runtime_py
examples_rclcpp_minimal_client          rosidl_typesupport_c
examples_rclcpp_minimal_composition     rosidl_typesupport_cpp
examples_rclcpp_minimal_publisher       rosidl_typesupport_fastrtps_c
examples_rclcpp_minimal_service         rosidl_typesupport_fastrtps_cpp
examples_rclcpp_minimal_subscriber      rosidl_typesupport_interface
examples_rclcpp_minimal_timer           rosidl_typesupport_introspection_c
examples_rclcpp_multithreaded_executor  rosidl_typesupport_introspection_cpp
examples_rclpy_executors                ros_workspace
examples_rclpy_minimal_action_client    rpyutils
examples_rclpy_minimal_action_server    rqt_action
examples_rclpy_minimal_client           rqt_bag
examples_rclpy_minimal_publisher        rqt_bag_plugins
examples_rclpy_minimal_service          rqt_common_plugins
examples_rclpy_minimal_subscriber       rqt_console
fastcdr                                 rqt_graph
fastdds_static_discovery.xsd            rqt_gui
fastrtps                                rqt_gui_cpp
fastrtps_cmake_module                   rqt_gui_py
fastRTPS_profiles.xsd                   rqt_image_view
foonathan_memory                        rqt_msg
foonathan_memory_vendor                 rqt_plot
geometry2                               rqt_publisher
geometry_msgs                           rqt_py_common
gmock_vendor                            rqt_py_console
gps_msgs                                rqt_reconfigure
gtest_vendor                            rqt_service_caller
gz_cmake_vendor                         rqt_shell
gz_common_vendor                        rqt_srv
gz_dartsim_vendor                       rqt_topic
gz_fuel_tools_vendor                    rttest
gz_gui_vendor                           rviz2
gz_math_vendor                          rviz_assimp_vendor
gz_msgs_vendor                          rviz_common
gz_ogre_next_vendor                     rviz_default_plugins
gz_physics_vendor                       rviz_ogre_vendor
gz_plugin_vendor                        rviz_plugins.xml
gz_rendering_vendor                     rviz_rendering
gz_sensors_vendor                       sdformat_urdf
gz_sim_vendor                           sdformat_vendor
gz_tools_vendor                         sdl2_vendor
gz_transport_vendor                     sensor_msgs
gz_utils_vendor                         sensor_msgs_py
image_geometry                          service_msgs
image_tools                             shape_msgs
image_transport                         simulation_interfaces
image_transport_plugins                 slam_toolbox
interactive_markers                     smclib
intra_process_demo                      solver_plugins.xml
joy                                     spdlog_vendor
kdl_parser                              sqlite3_vendor
keyboard_handler                        sros2
laser_geometry                          sros2_cmake
launch                                  statistics_msgs
launch_ros                              std_msgs
launch_testing                          std_srvs
launch_testing_ament_cmake              stereo_msgs
launch_testing_ros                      tango_icons_vendor
launch_xml                              teleop_twist_joy
launch_yaml                             teleop_twist_keyboard
libcurl_vendor                          tf2
liblz4_vendor                           tf2_bullet
libstatistics_collector                 tf2_eigen
libyaml_vendor                          tf2_eigen_kdl
lifecycle                               tf2_geometry_msgs
lifecycle_msgs                          tf2_kdl
logging_demo                            tf2_msgs
map_msgs                                tf2_py
marine_acoustic_msgs                    tf2_ros
mcap_vendor                             tf2_ros_py
message_filters                         tf2_sensor_msgs
nav_msgs                                tf2_tools
orocos_kdl_vendor                       theora_image_transport
osrf_pycommon                           tinyxml2_vendor
pcl_conversions                         tlsf
pcl_msgs                                tlsf_cpp
pendulum_control                        topic_monitor
pendulum_msgs                           tracetools
pluginlib                               trajectory_msgs
point_cloud_transport                   turtlebot3_gazebo
pybind11_vendor                         turtlesim
python_cmake_module                     type_description_interfaces
python_orocos_kdl_vendor                uncrustify_vendor
python_qt_binding                       unique_identifier_msgs
qt_dotgraph                             urdf
qt_gui                                  urdfdom
qt_gui_cpp                              urdf_parser_plugin
qt_gui_py_common                        vision_msgs
quality_of_service_demo_cpp             visualization_msgs
quality_of_service_demo_py              xacro
rcl                                     yaml_cpp_vendor
rcl_action                              zstd_image_transport
rclcpp                                  zstd_vendor
```

##  简单解释一下这里的类型

- string：ROS2 消息定义中的基础数据类型，类似 C++ 的 std::string。
- String：一个已经定义好的 ROS2 消息类型，可以类比为 C++ 中的类。
- data：String 消息类型中的字段，实际保存字符串内容。
- msg：根据 String 消息类型创建的消息对象。
- publish(msg)：发布整个消息对象，而不是单独发布 data。

最重要的一点： ROS2 话题通信使用的是***有明确类型定义的消息对象***。即使消息中只有一个 string data 字段，发布和订阅时也仍然是***以整个消息类型为单位进行通信***的。  

- std_msgs/msg/String：一个只包含 string data 字段的消息类型。
- example_interfaces/msg/String：另一个只包含 string data 字段的消息类型。
- 它们的数据结构相同，但类型身份不同，因此 ROS2 不会把它们当作同一种消息类型。

> 1. 例如，不能直接将 std_msgs::msg::String 类型的消息发布到要求 example_interfaces::msg::String 的发布者上。
> 2. 你可以把它们理解为 C++ 中两个不同命名空间下、同名且成员相同的类。

## 代码

### package.xml

```xml
<?xml version="1.0"?>
<?xml-model href="http://download.ros.org/schema/package_format3.xsd" schematypens="http://www.w3.org/2001/XMLSchema"?>
<package format="3">
  <name>my_py_pkg</name>
  <version>0.0.0</version>
  <description>TODO: Package description</description>
  <maintainer email="lwmfjc@gmail.com">ly</maintainer>
  <license>TODO: License declaration</license>

  <depend>rclpy</depend>
  <!--添加这行-->
  <depend>example_interfaces</depend>

  <test_depend>ament_copyright</test_depend>
  <test_depend>ament_flake8</test_depend>
  <test_depend>ament_pep257</test_depend>
  <test_depend>python3-pytest</test_depend>

  <export>
    <build_type>ament_python</build_type>
  </export>
</package>

```

### rebot_news_station.py

```python

```

> 1. `self.create_publisher(String,"robot_news",10)`：第三个参数 10 表示 QoS（服务质量）中的历史消息队列深度（Queue Depth），也就是最多缓存多少条消息。
> 2. 具体作用
> 假设发布者以每秒 10 条消息的速度发布，而订阅者只能以每秒 2 条消息的速度接收。
> 10：发布端最多保留 10 条历史消息供传输机制使用。
> 当缓存达到上限时，通常会丢弃较旧的消息，为新消息腾出空间（默认采用 KEEP_LAST 策略）。
> 如果订阅者处理速度跟不上，可能会错过部分消息。

