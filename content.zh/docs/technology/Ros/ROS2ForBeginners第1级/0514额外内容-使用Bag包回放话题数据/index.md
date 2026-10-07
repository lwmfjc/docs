---
title: "0514额外内容-使用Bag包回放话题数据"
description: "0514额外内容-使用Bag包回放话题数据"
categories:
  - 学习
tags:
  - ROS2
  - EdouardRenard
  - ROS2ForBeginners
date: 2026-10-06T21:45:55+08:00
lastmod: 2026-10-06T21:45:55+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 使用Bag包回放话题数据

> 这里讨论ros bag，在使用话题时非常有用

> 要理解什么是bag，以及为什么我们需要他们‘

> 假设你需要在室外测试机器人，需要在下雨时在室外测试机器人，假设你在大学工作但不能随时访问机器人，也许带到室外也不一定总在下雨但需要开发一个功能改善在室外下雨时的行为，**与其每次等待你能访问机器人，能把它带到室外且正下雨，不如做一次实验。** 假设在下雨时把它带到室外一个小时，你运行一次实验并**保存来自话题的所有数据**。
> 如果有一个相机话题，如果有轮子话题，想要将话题保存在数据集中，**然后稍后可以重放数据集**，接着就可以**针对这个数据集开发应用程序的功能**

> 使用ros2 bag，可以保存任意时长的数据，然后可以按需多次重放这些数据

> 先启动一个发布者

```bash
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 run my_py_pkg number_publisher
[INFO] [1791340090.551275468] [number_publisher]: Number publisher has been started.
```

> 再启动一个订阅者 ~~它订阅到消息后会累加后再发布到另一个话题~~ 

```bash
╭─ ~/HelloROS2/ros2_ws main
╰─❯ ros2 topic list
/number
/number_count
/parameter_events
/rosout
```

> 在新建的bag文件夹中操作

```bash
─ ~/HelloROS2/bags_ros2_ws main
╰─❯ ls

╭─ ~/HelloROS2/bags_ros2_ws main
╰─❯ ros2 bag -h
usage: ros2 bag [-h]
                Call `ros2 bag
                <command> -h` for more
                detailed usage. ...

Various rosbag related sub-commands

options:
  -h, --help       show this help
                   message and exit

Commands:
  burst    Burst data from a bag
  convert  Given an input bag, write out a new bag with different settings
  info     Print information about a bag to the screen
  list     Print information about available plugins to the screen
  play     Play back ROS data from a bag
  record   Record ROS data to a bag
  reindex  Reconstruct metadata file for a bag

  Call `ros2 bag <command> -h` for more detailed usage.
  
#录制话题（数据）  
╭─ ~/HelloROS2/bags_ros2_ws main
╰─❯ ros2 bag record /number_count
╭─ ~/HelloROS2/bags_ros2_ws main
╰─❯ ros2 bag record /number_count
[WARN] [ros2bag]: Positional "topics" argument deprecated. Please use optional "--topics" argument instead.
[INFO] [1791340443.316045173] [rosbag2_recorder]: Event publisher thread: Started
[INFO] [1791340443.316109933] [rosbag2_recorder]: Press SPACE for pausing/resuming
[INFO] [1791340443.335892429] [rosbag2_recorder]: Starting recording to 'rosbag2_2026_10_07-10_34_02'
[INFO] [1791340443.341957551] [rosbag2_recorder]: Listening for topics...
[INFO] [1791340443.342047883] [rosbag2_recorder]: Recording...
[INFO] [1791340443.342063496] [rosbag2_recorder]: Topics discovery started.
[INFO] [1791340443.350367035] [rosbag2_recorder]: Subscribed to topic '/number_count'
[INFO] [1791340443.350506088] [rosbag2_recorder]: All requested topics are subscribed. Stopping discovery...
[INFO] [1791340443.350583719] [rosbag2_recorder]: Topics discovery stopped.

#然后ctrl+C

```

> 录制期间所有发布到number_count话题的所有数据到记录在一个bag中了

> 查看

```bash
╭─ ~/HelloROS2/bags_ros2_ws main ?1          30s
╰─❯ ls
rosbag2_2026_10_07-10_34_02

╭─ ~/HelloROS2/bags_ros2_ws main ?1
╰─❯ cd rosbag2_2026_10_07-10_34_02

╭─ ~/HelloROS2/b/rosbag2_2026_10_07-10_34_02 main ?1
╰─❯ ls
metadata.yaml
rosbag2_2026_10_07-10_34_02_0.mcap

╭─ ~/HelloROS2/b/rosbag2_2026_10_07-10_34_02 main ?1
╰─❯ cat metadata.yaml
rosbag2_bagfile_information:
  version: 9
  storage_identifier: mcap
  duration:
    nanoseconds: 28000217976
  starting_time:
    nanoseconds_since_epoch: 1791340443504644767
  message_count: 29 #整个 rosbag 的消息总数（rosbag可能因为文件大小原因，被切分成多个）
  topics_with_message_count:
    - topic_metadata:
        name: /number_count  #话题名称
        type: example_interfaces/msg/Int64 #话题类型
        serialization_format: cdr
        offered_qos_profiles:
          - history: unknown
            depth: 0
            reliability: reliable
            durability: volatile
            deadline:
              sec: 9223372036
              nsec: 854775807
            lifespan:
              sec: 9223372036
              nsec: 854775807
            liveliness: automatic
            liveliness_lease_duration:
              sec: 9223372036
              nsec: 854775807
            avoid_ros_namespace_conventions: false
        type_description_hash: RIHS01_1b3b9a6502f560d079520c73c685a9550e5a1838d2cefd537fe0aba75a3639a0
      message_count: 29 #该话题的消息数
  compression_format: ""
  compression_mode: ""
  relative_file_paths:
    - rosbag2_2026_10_07-10_34_02_0.mcap
  files:
    - path: rosbag2_2026_10_07-10_34_02_0.mcap
      starting_time:
        nanoseconds_since_epoch: 1791340443504644767
      duration:
        nanoseconds: 28000217976
      message_count: 29  #这个 rosbag 所包含的这个 MCAP 文件中有 29 条消息。
  custom_data: ~
  ros_distro: jazzy% 
```

> 默认情况下会生成rosbag2+时间戳，这里我们将它重命名为test

```bash
╭─ ~/HelloROS2/bags_ros2_ws main ?1
╰─❯ ros2 bag record -o test /number_count
[WARN] [ros2bag]: Positional "topics" argument deprecated. Please use optional "--topics" argument instead.
[INFO] [1791340873.408324173] [rosbag2_recorder]: Press SPACE for pausing/resuming
[INFO] [1791340873.408495354] [rosbag2_recorder]: Event publisher thread: Started
[INFO] [1791340873.431551190] [rosbag2_recorder]: Starting recording to 'test'
[INFO] [1791340873.437463014] [rosbag2_recorder]: Listening for topics...
[INFO] [1791340873.437656479] [rosbag2_recorder]: Recording...
[INFO] [1791340873.437537060] [rosbag2_recorder]: Topics discovery started.
[INFO] [1791340873.465731580] [rosbag2_recorder]: Subscribed to topic '/number_count'
[INFO] [1791340873.465854314] [rosbag2_recorder]: All requested topics are subscribed. Stopping discovery...
[INFO] [1791340873.465875824] [rosbag2_recorder]: Topics discovery stopped.

#ctrl+c之后有一个test文件夹
╭─ ~/HelloROS2/bags_ros2_ws main ?1          59s
╰─❯ ls
rosbag2_2026_10_07-10_34_02  test

#再录制一个
╭─ ~/HelloROS2/bags_ros2_ws main ?1
╰─❯ ros2 bag record -o test /number_count
[WARN] [ros2bag]: Positional "topics" argument deprecated. Please use optional "--topics" argument instead.
[ERROR] [ros2bag]: Output folder 'test' already exists.

╭─ ~/HelloROS2/bags_ros2_ws main ?1
╰─❯ ros2 bag record -o test1 /number_count
[WARN] [ros2bag]: Positional "topics" argument deprecated. Please use optional "--topics" argument instead.
[INFO] [1791340978.418069466] [rosbag2_recorder]: Press SPACE for pausing/resuming
[INFO] [1791340978.418084516] [rosbag2_recorder]: Event publisher thread: Started
[INFO] [1791340978.478624982] [rosbag2_recorder]: Starting recording to 'test1'
[INFO] [1791340978.495586299] [rosbag2_recorder]: Subscribed to topic '/number_count'
[INFO] [1791340978.496241857] [rosbag2_recorder]: Listening for topics...
[INFO] [1791340978.496425472] [rosbag2_recorder]: Recording...
[INFO] [1791340978.496355418] [rosbag2_recorder]: Topics discovery started.
[INFO] [1791340978.496763251] [rosbag2_recorder]: All requested topics are subscribed. Stopping discovery...
[INFO] [1791340978.496869494] [rosbag2_recorder]: Topics discovery stopped.
```

> 查询bag的信息

```bash

╭─ ~/HelloROS2/bags_ros2_ws main ?1          38s
╰─❯ ros2 bag info test

Files:             test_0.mcap
Bag size:          5.4 KiB
Storage id:        mcap
ROS Distro:        jazzy
Duration:          4.999887495s
Start:             Oct  7 2026 10:59:36.116582550 (1791341976.116582550)
End:               Oct  7 2026 10:59:41.116470045 (1791341981.116470045)
Messages:          6 #注意，有六条
Topic information: Topic: /number_count | Type: example_interfaces/msg/Int64 | Count: 6 | Serialization Format: cdr
Service:           0
Service information:
```

> 再次播放bag
>  ~~将重放并再次发布（是发布，而不是直接打印）在该话题上接收到的所有数据~~ 

```bash
#现在ctrl+c所有的发布者和订阅者
#由于目前没有发布者所以必须要指定类型否则报错
ros2 topic echo /number_count example_interfaces/msg/Int64

ros2 bag play test

#这里有问题，第一次 ros2 bag play test 终端订阅者收不到任何消息然后play就播放完了，
#播放结束每收到消息，再次 
ros2 bag play test

#查看数据（不是运行！）
#╭─ ~/HelloROS2/ros2_ws main ?1
#╰─❯ ros2 topic echo /number_count example_interfaces/msg/Int64
#但是即使是这样还是少了两条
data: 108
---
data: 110
---
data: 112
---
data: 114
---
data: 104
---
data: 106
---
data: 108
---
data: 110
---
data: 112
---
data: 114
---
data: 104
---
data: 106
---
data: 108
---
data: 110
---
data: 112
---
data: 114
---

```

> 解决bag数据丢失减少的问题

```bash
╭─ ~/HelloROS2/ros2_ws main ?1       28s
╰─❯ ros2 topic echo /number_count example_interfaces/msg/Int64

╭─ ~/HelloROS2/bags_ros2_ws main ?1
╰─❯ ros2 bag play test --start-paused
[INFO] [1791342684.943316581] [rosbag2_player]: Set rate to 1
[INFO] [1791342684.972203230] [rosbag2_player]: Adding keyboard callbacks.
[INFO] [1791342684.972376545] [rosbag2_player]: Press SPACE for Pause/Resume
[INFO] [1791342684.972493798] [rosbag2_player]: Press CURSOR_RIGHT for Play Next Message
[INFO] [1791342684.972577961] [rosbag2_player]: Press CURSOR_UP for Increase Rate 10%
[INFO] [1791342684.972600571] [rosbag2_player]: Press CURSOR_DOWN for Decrease Rate 10%
[INFO] [1791342684.974489806] [rosbag2_player]: Playback until timestamp: -1

#然后等个10秒左右再按空格
#就能接收完整的数据
#不要再输入命令行，只是用来记录查看的数据
#╭─ ~/HelloROS2/ros2_ws main ?1    3m 45s
#╰─❯ ros2 topic echo /number_count example_interfaces/msg/Int64
data: 104
---
data: 106
---
data: 108
---
data: 110
---
data: 112
---
data: 114
---

```

## rosbag 重放时，为什么直接播放可能收不到完整数据？

在重放 rosbag 时，需要注意发布者和订阅者的启动时序。

假设原来的数据流为：

```bash
    /number_publisher
            │
            ▼
        /number
            │
            ▼
        /number_counter
            │
            ▼
      /number_count
```

重放 rosbag 时，可以关闭原来的发布者和订阅者，只保留 rosbag
作为数据发布者：

```bash
    rosbag play
        │
        ▼
    /number_count
        │
        ▼
    ros2 topic echo
```


由于当前没有其他节点发布 `/number_count`，因此需要明确指定消息类型：

```bash
ros2 topic echo /number_count example_interfaces/msg/Int64
```

但是，即使先启动 `ros2 topic echo`，然后再执行：

```bash
ros2 bag play test
```

也不一定能够保证完整收到第一条消息。

原因在于：

```bash
    ros2 topic echo
            │
            ▼
        创建订阅者
            │
            ▼
      DDS 发现与匹配
            │
            ▼
    与 rosbag 的 publisher 建立通信
```

而 `ros2 bag play` 一启动后就可能立即开始发布消息。

如果 bag 中的数据量很小、播放速度较快，就可能出现：

```bash
    rosbag 开始播放
          │
          ├── 发布前几条消息
          │
          ▼
      DDS 匹配完成
          │
          ▼
    echo 开始正常接收
```

这样前面的消息就可能没有被当前订阅者收到。

#### 解决方法

可以让 rosbag 先启动，但暂停播放：

```bash
ros2 bag play test --start-paused
```

此时 rosbag 播放器已经启动，但不会立即发布 bag 中的数据。

例如：

```bash
ros2 topic echo /number_count example_interfaces/msg/Int64
```

然后：

```bash
ros2 bag play test --start-paused
```

等待几秒，让 rosbag 的 publisher 和 echo 的 subscriber
完成 DDS 发现和匹配。

最后按 `Space` 开始播放。

此时数据可以完整接收：

```bash
    data: 104
    ---
    data: 106
    ---
    data: 108
    ---
    data: 110
    ---
    data: 112
    ---
    data: 114
    ---
```

因此，重放 rosbag 时，推荐的顺序是：

```bash
    ① 启动订阅者
          ↓
    ② 启动 rosbag，但使用 --start-paused
          ↓
    ③ 等待通信双方完成发现和匹配
          ↓
    ④ 按 Space 开始播放
          ↓
    ⑤ 订阅者接收完整的重放数据
```

`--start-paused` 的作用不是“保存历史消息”，而是给
ROS 2/DDS 足够的时间建立通信关系，然后再开始发送数据。

## 录制多个话题

```bash
╭─ ~/HelloROS2/bags_ros2_ws main ?1
╰─❯ ros2 bag record -o test3 /number_count /number
[WARN] [ros2bag]: Positional "topics" argument deprecated. Please use optional "--topics" argument instead.
[INFO] [1791343362.190359506] [rosbag2_recorder]: Press SPACE for pausing/resuming
[INFO] [1791343362.190388827] [rosbag2_recorder]: Event publisher thread: Started
[INFO] [1791343362.214156903] [rosbag2_recorder]: Starting recording to 'test3'
[INFO] [1791343362.219766120] [rosbag2_recorder]: Listening for topics...
[INFO] [1791343362.219844493] [rosbag2_recorder]: Topics discovery started.
[INFO] [1791343362.219951585] [rosbag2_recorder]: Recording...
[INFO] [1791343362.227106045] [rosbag2_recorder]: Subscribed to topic '/number' #订阅了话题 /number
[INFO] [1791343363.675138418] [rosbag2_recorder]: Subscribed to topic '/number_count' #订阅了话题 /number_count
[INFO] [1791343363.675324693] [rosbag2_recorder]: All requested topics are subscribed. Stopping discovery...
[INFO] [1791343363.675451357] [rosbag2_recorder]: Topics discovery stopped.
[INFO] [1791343368.054265033] [rosbag2_recorder]: Pausing recording.
[INFO] [1791343368.054576992] [rosbag2_cpp]: Writing remaining messages from cache to the bag. It may take a while
[INFO] [1791343368.062407156] [rosbag2_recorder]: Recording stopped
[INFO] [1791343368.071571684] [rosbag2_recorder]: Event publisher thread: Exited

╭─ ~/HelloROS2/bags_ros2_ws main ?1           7s
╰─❯ ros2 bag info test3

Files:             test3_0.mcap
Bag size:          8.1 KiB
Storage id:        mcap
ROS Distro:        jazzy
Duration:          5.000828312s
Start:             Oct  7 2026 11:22:42.723217230 (1791343362.723217230)
End:               Oct  7 2026 11:22:47.724045542 (1791343367.724045542)
Messages:          11 #总共11条
Topic information: Topic: /number | Type: example_interfaces/msg/Int64 | Count: 6 | Serialization Format: cdr
                   Topic: /number_count | Type: example_interfaces/msg/Int64 | Count: 5 | Serialization Format: cdr
Service:           0
Service information:

```

> -a，订阅所有的现有的主题

```bash
╭─ ~/HelloROS2/bags_ros2_ws main ?1          15s
╰─❯ ros2 bag record -o test5 -a
[INFO] [1791343594.278915721] [rosbag2_recorder]: Press SPACE for pausing/resuming
[INFO] [1791343594.279263377] [rosbag2_recorder]: Event publisher thread: Started
[INFO] [1791343594.301908305] [rosbag2_recorder]: Starting recording to 'test5'
[INFO] [1791343594.309957311] [rosbag2_recorder]: Subscribed to topic '/rosout'
[INFO] [1791343594.317054534] [rosbag2_recorder]: Subscribed to topic '/parameter_events'
[INFO] [1791343594.322585273] [rosbag2_recorder]: Subscribed to topic '/number'
[INFO] [1791343594.324997231] [rosbag2_recorder]: Subscribed to topic '/events/write_split'
[INFO] [1791343594.325702820] [rosbag2_recorder]: Listening for topics...
[INFO] [1791343594.325905376] [rosbag2_recorder]: Recording...
[INFO] [1791343594.325783750] [rosbag2_recorder]: Topics discovery started.
[INFO] [1791343595.634052189] [rosbag2_recorder]: Subscribed to topic '/number_count'

#查看test5
╭─ ~/HelloROS2/bags_ros2_ws main ?1        ✘ INT
╰─❯ ros2 bag info test5

Files:             test5_0.mcap
Bag size:          32.2 KiB
Storage id:        mcap
ROS Distro:        jazzy
Duration:          41.513057732s
Start:             Oct  7 2026 11:26:34.309401630 (1791343594.309401630)
End:               Oct  7 2026 11:27:15.822459362 (1791343635.822459362)
Messages:          96
Topic information: Topic: /events/write_split | Type: rosbag2_interfaces/msg/WriteSplitEvent | Count: 0 | Serialization Format: cdr
                   Topic: /number | Type: example_interfaces/msg/Int64 | Count: 42 | Serialization Format: cdr
                   Topic: /number_count | Type: example_interfaces/msg/Int64 | Count: 40 | Serialization Format: cdr
                   Topic: /parameter_events | Type: rcl_interfaces/msg/ParameterEvent | Count: 0 | Serialization Format: cdr
                   Topic: /rosout | Type: rcl_interfaces/msg/Log | Count: 14 | Serialization Format: cdr
Service:           0
Service information:
```

> 现在重放一下test3，也就是/number数据有6条， /number_count有5条

```bash
#两个订阅者

╭─ ~/HelloROS2/ros2_ws main ?1
╰─❯ ros2 topic echo /number example_interfaces/msg/Int64

╭─ ~/HelloROS2/ros2_ws main ?1
╰─❯ ros2 topic echo /number_count example_interfaces/msg/Int64

#回放全部数据
╭─ ~/HelloROS2/bags_ros2_ws main ?1
╰─❯ ros2 bag play test3 --start-paused   [INFO] [1791344447.663780496] [rosbag2_player]: Set rate to 1
[INFO] [1791344447.694187158] [rosbag2_player]: Adding keyboard callbacks.
[INFO] [1791344447.694306191] [rosbag2_player]: Press SPACE for Pause/Resume
[INFO] [1791344447.694368653] [rosbag2_player]: Press CURSOR_RIGHT for Play Next Message
[INFO] [1791344447.694466705] [rosbag2_player]: Press CURSOR_UP for Increase Rate 10%
[INFO] [1791344447.694561458] [rosbag2_player]: Press CURSOR_DOWN for Decrease Rate 10%
[INFO] [1791344447.696254534] [rosbag2_player]: Playback until timestamp: -1
[INFO] [1791344461.420207219] [rosbag2_player]: Resuming play.


#查看数据
#╭─ ~/HelloROS2/ros2_ws main ?1
#╰─❯ ros2 topic echo /number example_interfaces/msg/Int64
data: 2
---
data: 2
---
data: 2
---
data: 2
---
data: 2
---
data: 2
---

#查看数据
#╭─ ~/HelloROS2/ros2_ws main ?1
#╰─❯ ros2 topic echo /number_count example_interfaces/msg/Int64
data: 240
---
data: 242
---
data: 244
---
data: 246
---
data: 248
---

```

> 只回放某个话题

```bash
╭─ ~/HelloROS2/ros2_ws main ?1    1m 54s
╰─❯ ros2 topic echo /number example_interfaces/msg/Int64

╭─ ~/HelloROS2/ros2_ws main ?1    1m 46s
╰─❯ ros2 topic echo /number_count example_interfaces/msg/Int64


╭─ ~/HelloROS2/bags_ros2_ws main ?1          20s
╰─❯ ros2 bag play test3 --start-paused --topics /number_count
[INFO] [1791344573.189532514] [rosbag2_player]: Set rate to 1
[INFO] [1791344573.558582772] [rosbag2_player]: Adding keyboard callbacks.
[INFO] [1791344573.558827101] [rosbag2_player]: Press SPACE for Pause/Resume
[INFO] [1791344573.558925553] [rosbag2_player]: Press CURSOR_RIGHT for Play Next Message
[INFO] [1791344573.559021156] [rosbag2_player]: Press CURSOR_UP for Increase Rate 10%
[INFO] [1791344573.559080788] [rosbag2_player]: Press CURSOR_DOWN for Decrease Rate 10%
[INFO] [1791344573.560810477] [rosbag2_player]: Playback until timestamp: -1
[INFO] [1791344582.394853654] [rosbag2_player]: Resuming play.

#只有number_count收到了消息
#╭─ ~/HelloROS2/ros2_ws main ?1    1m 46s
#╰─❯ ros2 topic echo /number_count example_interfaces/msg/Int64
data: 240
---
data: 242
---
data: 244
---
data: 246
---
data: 248
---
```