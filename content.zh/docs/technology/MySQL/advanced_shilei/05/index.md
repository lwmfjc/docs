---
title: 05日志
description: 05日志
categories:
  - 学习
tags:
  - 施磊
  - MySQL高级
date: 2025-03-24T19:14:08+08:00
lastmod: 2025-03-24T19:14:08+08:00
cssAttach:
  - book01
cssclasses:
  - book01
---

# undolog
## 作用
1. 恢复某条记录原始状态
2. 记录修改过程，MVCC的原理，结合事务id知道哪些数据可见
`undo log的修改本身会被记录到redo log中。即使undo log未刷盘，崩溃恢复时也可以通过redo log重建undo log。`
# redolog
1. `数据持久性`--事务提交后，buffer pool一些脏页没有写入数据库磁盘文件。重启时，利用redolog恢复`(表空间、页号、偏移量、数值)`的数据（磁盘数据）
2. 由于redolog有几种策略时机刷入磁盘。另有额外线程每隔1s不断刷入redolog buffer pool数据到redolog磁盘日志文件中，如果事务未提交但是刷入了redolog日志文件也无妨。可以根据一些标识，找到哪个事务是未提交的，然后再用undolog恢复原始状态。
```shell
root@db211:/var/lib/mysql# ls
auto.cnf	 ibdata1	     public_key.pem
ca-key.pem	 ib_logfile0 (redolog)	     server-cert.pem
ca.pem		 ib_logfile1 (redolog)		 server-key.pem
client-cert.pem  ibtmp1		     sys
client-key.pem	 mysql		     test
db211-slow.log	 performance_schema  xx
ib_buffer_pool 	 private_key.pem

```
# 大小配置
1. Buffer Pool
参数：innodb_buffer_pool_size
默认值：128MB（适用于MySQL 5.7及更高版本，包括MySQL 8.0）。
作用：缓存表数据和索引，加速数据读写操作。它是InnoDB性能的核心，建议在生产环境中设置为物理内存的50%~80%。
调整建议：
```mysql
-- 查看当前配置
SHOW VARIABLES LIKE 'innodb_buffer_pool_size';

-- 动态调整（需重启生效）
SET GLOBAL innodb_buffer_pool_size = 2147483648; -- 设置为2GB
```
2. Redo Log Buffer
参数：innodb_log_buffer_size
默认值：16MB（适用于MySQL 5.7及更高版本）。
作用：临时存储事务产生的Redo Log，用于崩溃恢复。事务提交时，Redo Log会先写入此缓冲区，再按策略刷到磁盘的Redo Log文件（ib_logfile0、ib_logfile1）。
调整建议：若事务频繁或有大事务（如批量插入），可适当增大此值以减少磁盘I/O。
```mysql
-- 查看当前配置
SHOW VARIABLES LIKE 'innodb_log_buffer_size';

-- 动态调整（需修改配置文件并重启）
SET GLOBAL innodb_log_buffer_size = 33554432; -- 设置为32MB（需重启生效）
```
3. Undo Log Buffer
参数：innodb_undo_log_buffer_size
默认值：16MB（适用于MySQL 8.0+；MySQL 5.7中默认为1MB）。
作用：临时存储事务产生的Undo Log，用于回滚和MVCC多版本控制。Undo Log在事务提交前会先写入此缓冲区，再异步刷到磁盘的Undo表空间。
版本差异：
MySQL 5.7：默认1MB，需手动调整。
MySQL 8.0+：默认16MB，并支持动态调整。
调整建议：
```mysql
-- 查看当前配置
SHOW VARIABLES LIKE 'innodb_undo_log_buffer_size';

-- 动态调整（MySQL 8.0+支持）
SET GLOBAL innodb_undo_log_buffer_size = 67108864; -- 设置为64MB
```
# 顺序
```shell
UPDATE语句执行流程：
1. 事务开始
   │
   ├─ 1. 写Undo Log到Undo Log Buffer（记录旧值）
   │
   ├─ 2. 修改Buffer Pool中的数据页（生成脏页）
   │
   ├─ 3. 写Redo Log到Redo Log Buffer（记录物理变更）
   │
   └─ 4. 事务提交
       │
       ├─ 4.1 Redo Log Prepare阶段（刷盘）
       │
       ├─ 4.2 写Binlog并刷盘
       │
       └─ 4.3 Redo Log Commit阶段（标记提交）
           │
           └─ 5. 后台异步刷脏页到磁盘

```
