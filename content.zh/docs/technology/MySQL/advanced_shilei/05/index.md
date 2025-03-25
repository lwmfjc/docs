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
# update语句执行流程
## 流程
1. 事务开始
	1. 写Undo Log到Undo Log Buffer（记录旧值）
	2. 修改Buffer Pool中的数据页（生成脏页） 
	3. 写Redo Log到Redo Log Buffer（记录物理变更）
2. 事务提交
	1. Redo Log 标记为 Prepare
	2. 写Binlog并刷盘
	3. Redo Log Commit阶段（标记提交）
### redolog的刷盘策略
1. Redo Log Buffer 空间不足：当 Redo Log Buffer 的写入速度超过刷盘速度时，InnoDB 会强制刷盘以释放空间。
2. 后台线程定期刷盘：InnoDB 的后台线程（如 log_writer 和 log_flusher）会周期性刷盘（默认每秒一次，由 innodb_flush_log_at_timeout 控制）。
3. 参数配置触发
	1. 0：设置为 0 的时候，表示每次事务提交时不进行刷盘操作。这种方式性能最高，但是也最不安全，因为如果 MySQL 挂了或宕机了，可能会丢失最近 1 秒内的事务。
	2. 1：设置为 1 的时候，表示每次事务提交时都将进行刷盘操作。这种方式性能最低，但是也最安全，因为只要事务提交成功，redo log 记录就一定在磁盘里，不会有任何数据丢失。
	3. 2：设置为 2 的时候，表示每次事务提交时都只把 log buffer 里的 redo log 内容写入 page cache（文件系统缓存）。page cache 是专门用来缓存文件的，这里被缓存的文件就是 redo log 文件。这种方式的性能和安全性都介于前两者中间。

~~这里其实有个疑问，就是redolog并不是事务提交后才刷盘的，而是很有可能事务提交前就刷盘了。如果提交前刷盘了，之后系统宕机了，那么redolog磁盘文件就多出了一些未提交事务的日志。解决办法：可以通过一些属性，在undolog中找到未提交事务的id，然后通过undolog回滚未提交事务。~~
### UndoLogBuffer一定要在修改buffer pool前写入吗
undolog是用来记录数据的旧值的，如果修改buffer pool后再写入undolog buffer，如果修改buffer pool后，之后一段时间内如果redo log已经写入并刷盘，且undolog为记录，则此时宕机重启后redo log就多了一次修改，而无法通过undolog恢复了
### RedoLog标记为Prepare的时机
是在事务提交时，redolog的两阶段提交，跟redolog的落盘其实没有很直接的关系，即使事务commit前部分redolog日志可能已经落盘，但是未涉及到binlog日志的落盘。binlog日志落盘是在事务commit时。先把redolog标记为prepare，之后将binlog日志落盘，最后将redolog标记为commit状态。

~~目的是为了解决redolog和binlog落盘时，因为系统宕机可能出现的数据不一致问题~~
### 两阶段提交的作用
假设落盘顺序为redolog-~~---~~->binlog，中间宕机，则重启后binlog中数据偏少。反之偏多。都是不一致  

如果是redolog-prepare--~~--①--~~-->binlog--~~--②--~~-->redolog-commit  

如果在①宕机不会有影响。因为mysql使用redolog恢复数据时，会发现redolog为prepare阶段且==没有对应的binlog日志==，那么恢复后会回滚数据(利用undolog)  

如果在②宕机，mysql使用redolog恢复数据时，会发现redolog为prepare阶段且==有对应的binlog日志==，那么会直接恢复数据并且==不回滚数据(因为binlog日志是完整的)==