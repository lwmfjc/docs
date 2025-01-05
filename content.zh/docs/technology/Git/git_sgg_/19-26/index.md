---
title: 19-26_git_尚硅谷
description: '团队协作'
categories:
  - 学习
tags:
  - git_尚硅谷
date: 2022-07-24 16:46:04
updated: 2022-07-27 21:05:04
---

# 介绍

使用代码托管中心（远程服务器）
![ly-20241212142124425](img/ly-20241212142124425.png)

- 团队内写作
     push--clone--push---
  --pull
  ![ly-20241212142124625](img/ly-20241212142124625.png)
- 跨团队写作
  fork（到自己的远程库）---clone
  ![ly-20241212142124707](img/ly-20241212142124707.png)

# 创建远程库&创建别名

- 官网：https://github.com
- 现在yuebuqun注册一个账号
  创建一个远程库git-demo，创建成功
  ![ly-20241212142124787](img/ly-20241212142124787.png)
- 创建远程库别名
  git remote -v （查看别名）
  为远程库创建别名
  ```git remote add git-demo https://github.com/lwmfjc/git-demo.git```
  别名创建成功 fetch和push都可以使用别名
  ![ly-20241212142124868](img/ly-20241212142124868.png)

# 推送本地库到远程库

- 推送master分支
  切换```git checkout master```
- 推送
  git push git-demo master
  ![ly-20241212142124947](img/ly-20241212142124947.png)

# 拉取远程库到本地库

- ```git pull git-demo master```
  结果
  ![ly-20241212142125028](img/ly-20241212142125028.png)

# 克隆远程库到本地

- git clone xxxxxxx/git-demo.git
  ![ly-20241212142125111](img/ly-20241212142125111.png)
  clone之后有默认的别名，且已经初始化了本地库

# 团队内写作

- lhc修改了git-demo下的hello.txt
- 之后进行git add hello.txt
- git commit -m "lhc-commit " hello.txt
- 现在进行push
  git push origin master
  出错了
  ![ly-20241212142125194](img/ly-20241212142125194.png)
- 使用ybq，对库进行设置，管理成员
  ![ly-20241212142125275](img/ly-20241212142125275.png)
- 添加成员即可
  输入账号名
  ![ly-20241212142125354](img/ly-20241212142125354.png)
- 将邀请函
  ![ly-20241212142125433](img/ly-20241212142125433.png)
  发送给lhc
  ![ly-20241212142125516](img/ly-20241212142125516.png)
- 现在再次推送，则推送成功
  ![ly-20241212142125598](img/ly-20241212142125598.png)

# 团队外合作

- 先把别人的项目fork下来
  ![ly-20241212142125682](img/ly-20241212142125682.png)

- 之后进行修改并且commit
  ![ly-20241212142125760](img/ly-20241212142125760.png)

- pull request (拉取请求)
  ![ly-20241212142125839](img/ly-20241212142125839.png)

  - 请求
    东方不败：![ly-20241212142125920](img/ly-20241212142125920.png)

  - 岳不群：看到别人发过来的请求
    ![ly-20241212142125997](img/ly-20241212142125997.png)

    可以同意
    ![ly-20241212142126076](img/ly-20241212142126076.png)
    合并申请
    ![ly-20241212142126158](img/ly-20241212142126158.png)

# SSH免密登录

![ly-20241212142126237](img/ly-20241212142126237.png)

- ssh免密公钥添加
  
  > 添加之前,
>
  > ```csharp
  > git config --global user.name "username"
  > git config --global user.email useremail@qq.com 
  > ```
  
删除~/.ssh 
  使用
  
  ```shell
  ssh-keygen -t rsa  -C xxxx@xx.com
  # 再次到~/.ssh 查看
  cat id_rsa  私钥
  ```
  
- 把私钥复制到 账号--设置--ssh and gpgkeys
  

![ly-20241212142126317](img/ly-20241212142126317.png)



- 测试是否成功