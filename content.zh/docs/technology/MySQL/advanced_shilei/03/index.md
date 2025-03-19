---
title: 03存储引擎
description: 03存储引擎
categories:
  - 学习
tags:
  - 施磊
  - MySQL高级
date: 2025-03-19T09:52:44+08:00
lastmod: 2025-03-19T09:52:44+08:00
cssAttach:
  - book01
cssclasses:
  - book01
---
表结构、数据、索引  
# 文件目录
```mysql
 root@db211:/var/lib/mysql/mysql# ls | tail -16
tables_priv.frm
tables_priv.MYD
tables_priv.MYI
time_zone.frm
time_zone.ibd
time_zone_leap_second.frm
time_zone_leap_second.ibd
time_zone_name.frm
time_zone_name.ibd
time_zone_transition.frm
time_zone_transition.ibd
time_zone_transition_type.frm   #INNODB存储引擎-表结构
time_zone_transition_type.ibd   #INNODB存储引擎-表数据+表索引（包括所有索引）
user.frm   #MyISAM存储引擎-表结构
user.MYD   #MyISAM存储引擎-表数据
user.MYI   #MyISAM存储引擎-表索引
```
INNODE存储引擎的表主键聚簇索引和数据在同一个文件（所以即使没有设置主键，innodb也会为每一行自动生成一个默认的隐藏主键列，用来形成B+树）
# 索引
## 索引创建
### 建表时创建
```mysql
create table index1( id int, name varchar(20), index idx_id_name (id,name));
```
### 后续添加
```mysql
create index idx_name on bank_bill (name);
```
