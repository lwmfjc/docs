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

> 编辑 `my_cpp_pkg/src/my_first_node.cpp`

```cpp
#include "rclcpp/rclcpp.hpp"

int main(int argc,char** argv)
{
    //使用rclcpp初始化ros2通信
    //rclcpp是命名空间
    rclcpp::init(argc,argv);
    //auto这里自动类型是智能指针，这里
    //是std::shared_ptr<rclcpp::Node>，
    //会处理内存定位和销毁内存的问题
    //ros2中所有东西都使用智能指针
    //创建了一个指向节点对象的共享指针
    //要指定文件名，否则colcon build时会报错
    //传递节点名称作为参数
    auto node=std::make_shared<rclcpp::Node>("cpp_test");
    //node-> 将使用共享指针内部的那个类型的对象
    //node.  将使用共享指针自己
    RCLCPP_INFO(node->get_logger(),"Hello world");
    //关闭
    rclcpp::shutdown();
    return 0;
}
```

> 安装扩展 cmake

现在要打开 CMakeList.txt,文件中的测试部分可以删除（我这里先注释了）
```cmake
# if(BUILD_TESTING)
#   find_package(ament_lint_auto REQUIRED)
#   # the following line skips the linter which checks for copyrights
#   # comment the line when a copyright and license is added to all source files
#   set(ament_cmake_copyright_FOUND TRUE)
#   # the following line skips cpplint (only works in a git repo)
#   # comment the line when this package is in a git repo and when
#   # a copyright and license is added to all source files
#   set(ament_cmake_cpplint_FOUND TRUE)
#   ament_lint_auto_find_test_dependencies()
# endif()
```

> 如果在c++包中添加新的依赖项，那么需要在 package.xml中的 package标签添加depend标签。
> 如果需要该依赖项来编译某些东西，那么需要在CMakeList.txt中使用find_package( ) 来使用

最终的CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.8)
project(my_cpp_pkg)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# find dependencies
find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)

#添加-可执行文件及其依赖项
add_executable(cpp_node src/my_first_node.cpp)
ament_target_dependencies(cpp_node rclcpp)

#添加-安装
#将可执行文件安装到 lib/${PROJECT_NAME}
install(TARGETS
  cpp_node
  DESTINATION lib/${PROJECT_NAME}
)

ament_package()

```

> 构建安装、加载构建后的环境、启动节点

```bash
#构建并安装Python的功能包
╭─ ~/HelloROS2/ros2_ws main !2   
╰─❯ colcon build --packages-select my_cpp_pkg
Starting >>> my_cpp_pkg
Finished <<< my_cpp_pkg [13.4s]

Summary: 1 package finished [13.9s]
```

> 如下，可执行文件的位置： `install/my_cpp_pkg` 下的 `lib/my_cpp_pkg/cpp_node` 

```bash
╭─ ~/HelloROS2/ros2_ws main !2
╰─❯ ls install
COLCON_IGNORE     local_setup.sh            local_setup.zsh  setup.bash  setup.zsh
local_setup.bash  _local_setup_util_ps1.py  my_cpp_pkg       setup.ps1
local_setup.ps1   _local_setup_util_sh.py   my_py_pkg        setup.sh

╭─ ~/HelloROS2/ros2_ws main !2
╰─❯ tree install/my_cpp_pkg
install/my_cpp_pkg
├── lib
│   └── my_cpp_pkg
│       └── cpp_node
└── share
    ├── ament_index
    │   └── resource_index
    │       ├── package_run_dependencies
    │       │   └── my_cpp_pkg
    │       ├── packages
    │       │   └── my_cpp_pkg
    │       └── parent_prefix_path
    │           └── my_cpp_pkg
    ├── colcon-core
    │   └── packages
    │       └── my_cpp_pkg
    └── my_cpp_pkg
        ├── cmake
        │   ├── my_cpp_pkgConfig.cmake
        │   └── my_cpp_pkgConfig-version.cmake
        ├── environment
        │   ├── ament_prefix_path.dsv
        │   ├── ament_prefix_path.sh
        │   ├── path.dsv
        │   └── path.sh
        ├── hook
        │   ├── cmake_prefix_path.dsv
        │   ├── cmake_prefix_path.ps1
        │   └── cmake_prefix_path.sh
        ├── local_setup.bash
        ├── local_setup.dsv
        ├── local_setup.sh
        ├── local_setup.zsh
        ├── package.bash
        ├── package.dsv
        ├── package.ps1
        ├── package.sh
        ├── package.xml
        └── package.zsh

15 directories, 24 files

#是可以直接执行的
╭─ ~/HelloROS2/ros2_ws main !2
╰─❯ ./install/my_cpp_pkg/lib/my_cpp_pkg/cpp_node
[INFO] [1791026007.189362531] [cpp_test]: Hello world

#当然，我们应该使用ROS2命令
╭─ ~/HelloROS2/ros2_ws main !2
╰─❯ source install/setup.zsh

╭─ ~/HelloROS2/ros2_ws main !2
╰─❯ cd ~

╭─ ~
╰─❯ ros2 run my_cpp_pkg cpp_node
#cpp_test是节点名称
[INFO] [1791026088.433798389] [cpp_test]: Hello world


```

和Python节点一样，C++节点也有三个注意的：  
- my_first_node.cpp
- 节点名称(cpp_test) `auto node=std::make_shared<rclcpp::Node>("cpp_test");`
- 可执行文件名称(cpp_node)：`add_executable(cpp_node src/my_first_node.cpp)

当然，根据喜好，也可以使用一样的名称

## 完整c++代码

> 添加spin保持存活

```cpp
#include "rclcpp/rclcpp.hpp"

int main(int argc,char** argv)
{
    //使用rclcpp初始化ros2通信
    //rclcpp是命名空间
    rclcpp::init(argc,argv);
    //auto这里自动类型是智能指针，这里
    //是std::shared_ptr<rclcpp::Node>，
    //会处理内存定位和销毁内存的问题
    //ros2中所有东西都使用智能指针
    //创建了一个指向节点对象的共享指针
    //传递节点名称作为参数
    auto node=std::make_shared<rclcpp::Node>("cpp_test");
    //node-> 将使用共享指针内部的那个类型的对象
    //node.  将使用共享指针自己
    RCLCPP_INFO(node->get_logger(),"Hello world");
    //传入共享指针即可
    //spin将使节点保持存活
    rclcpp::spin(node);
    //关闭
    rclcpp::shutdown();
    return 0;
}
```

> 每当修改代码都应当：build、source、run

```bash
╭─ ~
╰─❯ cd HelloROS2/ros2_ws

╭─ ~/HelloROS2/ros2_ws main !2
╰─❯ colcon build --packages-select my_cpp_pkg
Starting >>> my_cpp_pkg
Finished <<< my_cpp_pkg [11.3s]

Summary: 1 package finished [11.7s]

╭─ ~/HelloROS2/ros2_ws main !2                                                   13s
╰─❯ source install/setup.zsh

╭─ ~/HelloROS2/ros2_ws main !2
╰─❯ ros2 run my_cpp_pkg cpp_node
[INFO] [1791026550.899327044] [cpp_test]: Hello world

```

# 改进节点-以面向对象编程

```cpp
//什么都不做的一个标准模版

#include "rclcpp/rclcpp.hpp"

// public表示子类继承的父类的成员变量/方法，
// 最高只能是public。如果是class MyNode:protected rclcpp::Node
// 则原来父类中的public成员变量变成protected，但是原来的protected
// 和private成员变量则不变
class MyNode : public rclcpp::Node
{

public:
    // 创建这个子类对象时，先初始化父类部分，
    // 并将 ROS 2 节点名称设置为 cpp_test

    // 因为在执行子类构造函数体之前，父类部分就必须先完成初始化。对于 rclcpp::Node 这样的类，通常需要在初始化列表中传入节点名称。

    // 对于MyNode()： 后面的初始化列表，C++ 有固定
    // 的初始化顺序，不完全取决于冒号后面的书写顺序：
    // 1. 先初始化父类（Node("cpp_test")）
    // 2. 再按照成员变量在类中声明的顺序初始化
    // 3. 最后执行构造函数体 {}
    MyNode() : Node("cpp_test")
    {

    } 
};

int main(int argc, char **argv)
{
    // 使用rclcpp初始化ros2通信
    // rclcpp是命名空间
    rclcpp::init(argc, argv);
    // auto这里自动类型是智能指针，这里
    // 是std::shared_ptr<MyNode>，
    // 会处理内存定位和销毁内存的问题
    // ros2中所有东西都使用智能指针
    // 创建了一个指向节点对象的共享指针
    // 传递节点名称作为参数
    auto node = std::make_shared<MyNode>("cpp_test");
    // 传入共享指针即可
    // spin将使节点保持存活
    rclcpp::spin(node);
    // 关闭
    rclcpp::shutdown();
    return 0;
}
```

## 添加定时器功能

```cpp
#include "rclcpp/rclcpp.hpp"

// public表示子类继承的父类的成员变量/方法，
// 最高只能是public。如果是class MyNode:protected rclcpp::Node
// 则原来父类中的public成员变量变成protected，但是原来的protected
// 和private成员变量则不变
class MyNode : public rclcpp::Node
{

public:
    // 创建这个子类对象时，先初始化父类部分，
    // 并将 ROS 2 节点名称设置为 cpp_test

    // 因为在执行子类构造函数体之前，父类部分就必须先完成初始化。对于 rclcpp::Node 这样的类，通常需要在初始化列表中传入节点名称。

    // 对于MyNode()： 后面的初始化列表，C++ 有固定
    // 的初始化顺序，不完全取决于冒号后面的书写顺序：
    // 1. 先初始化父类（Node("cpp_test")）
    // 2. 再按照成员变量在类中声明的顺序初始化
    // 3. 最后执行构造函数体 {}
    MyNode() : Node("cpp_test"),counter_(0)
    {
        // 去掉这行那就是标准的模版，以后直接复制来用即可
        // 这里this是一个指针，不是对象
        RCLCPP_INFO(this->get_logger(), "Hello world");
        timer_=this->create_wall_timer(std::chrono::seconds(1),
                        std::bind(&MyNode::timerCallback,this));
    }

private:
    void timerCallback()
    {
        RCLCPP_INFO(this->get_logger(),"Hello %d",counter_);
        counter_++;
    }
    // 这也是一个共享指针
    rclcpp::TimerBase::SharedPtr timer_;
    int counter_;
};

int main(int argc, char **argv)
{
    // 使用rclcpp初始化ros2通信
    // rclcpp是命名空间
    rclcpp::init(argc, argv);
    // auto这里自动类型是智能指针，这里
    // 是std::shared_ptr<MyNode>，
    // 会处理内存定位和销毁内存的问题
    // ros2中所有东西都使用智能指针
    // 创建了一个指向节点对象的共享指针
    // 传递节点名称作为参数
    auto node = std::make_shared<MyNode>("cpp_test");
    // 传入共享指针即可
    // spin将使节点保持存活
    rclcpp::spin(node);
    // 关闭
    rclcpp::shutdown();
    return 0;
}
```

> build,source,run

```bash
╭─ ~/HelloROS2/ros2_ws main   
╰─❯ colcon build --packages-select my_cpp_pkg
Starting >>> my_cpp_pkg
Finished <<< my_cpp_pkg [12.3s]

Summary: 1 package finished [12.7s]

╭─ ~/HelloROS2/ros2_ws main    
╰─❯ colcon build --packages-select my_cpp_pkg
Starting >>> my_cpp_pkg
Finished <<< my_cpp_pkg [12.3s]

Summary: 1 package finished [12.7s]

╭─ ~/HelloROS2/ros2_ws main !1    
╰─❯ source install/setup.zsh

╭─ ~/HelloROS2/ros2_ws main !1
╰─❯ ros2 run my_cpp_pkg cpp_node
[INFO] [1791035907.146215959] [cpp_test]: Hello world
[INFO] [1791035908.147690835] [cpp_test]: Hello 0
[INFO] [1791035909.147628055] [cpp_test]: Hello 1
[INFO] [1791035910.147619577] [cpp_test]: Hello 2
[INFO] [1791035911.147629455] [cpp_test]: Hello 3
[INFO] [1791035912.147577068] [cpp_test]: Hello 4
```