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
	   修改BufferPool后，还会MySQL还会生成对应的==Binlog 事件==逻辑操作记录），先写入线程的私有内存缓冲区（==Binlog Cache==）
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
### binlog是直接写入磁盘的吗

1. 事务提交前：Binlog事件会暂时存储在BinlogCache中（每个客户端线程有独立的缓存）。
2. 事务提交时：将BinlogCache中的事件写入Binlog文件（位于文件系统的 Page Cache，即操作系统的内存缓冲区）。根据参数sync_binlog的设置，决定是否立即将 Page Cache 的内容刷到磁盘。
	1. =0, 操作系统定期刷盘
	2. =1, 每次事务提交时同步刷盘，保证 Binlog 持久化（安全但性能较低）
	3. =N, 每N次事务提交后批量刷盘
3. 对上述三种情况分析
	1. 当sync_binlog=0或N时，binlog写入Page Cache后立即标记redo log为commit，无需等待磁盘刷盘。很明显，如果刷盘前系统宕机，很容易导致binlog磁盘文件数据缺失
	2. sync_binlog=1，确保每次提交刷盘Binlog。
### RedoLog标记为Prepare的时机

是在事务提交时，redolog的两阶段提交，跟redolog的落盘其实没有很直接的关系，即使事务commit前部分redolog日志可能已经落盘，但是未涉及到binlog日志的落盘。binlog日志落盘是在事务commit时。先把redolog标记为prepare，之后将binlog日志落盘，最后将redolog标记为commit状态。

~~目的是为了解决redolog和binlog落盘时，因为系统宕机可能出现的数据不一致问题~~
### 两阶段提交的作用
假设落盘顺序为redolog-~~---~~->binlog，中间宕机，则重启后binlog中数据偏少。反之偏多。都是不一致  

如果是redolog-prepare--~~--①--~~-->binlog--~~--②--~~-->redolog-commit  

如果在①宕机不会有影响。因为mysql使用redolog恢复数据时，会发现redolog为prepare阶段且==没有对应的binlog日志==，那么恢复后会回滚数据(利用undolog)  

如果在②宕机，mysql使用redolog恢复数据时，会发现redolog为prepare阶段且==有对应的binlog日志==，那么会直接恢复数据并且==不回滚数据(因为binlog日志是完整的)==
# 刷盘时机
## redolog

1. [强制]redolog buffer空间(==innodb_log_buffer_size==参数)不足时(比如超过一半)
2. innodb_flush_log_at_trx_commit 
	1. =1: 每次事务提交时刷盘，保证持久性，性能偏低
	2. =0: 事务提交时不刷盘
	3. =2：事务提交时写入操作系统缓存，依赖系统刷盘
3. [强制]默认情况下后台线程每秒钟刷盘一次(innodb_flush_log_at_timeout 参数)

## bufferpool

- 刷盘对象：脏页 

1. 后台线程==持续监控==脏页比例,超过阈值刷盘
2. 可以手动触发(`SET GLOBAL innodb_max_dirty_pages_pct = 0; `)

## undolog

1. ==事务提交时==(异步刷到磁盘的Undo表空间，不阻塞事务提交)
	1. Undo Log 的修改本身会记录到 Redo Log，因此其持久化由 Redo Log 机制间接保证
2. 空间不足
3. 后台线程==定时刷盘==, 期清理已提交事务的UndoLog，并异步刷盘

# 优化相关
- 查询的单位是字节
1. innodb_buffer_pool_size: InnoDB存储引擎用于缓存数据和索引的内存池大小。 适当设置此值可以减少磁盘I/O，提高读写速度(可以增大它来减少磁盘io(减少buff pool刷盘的几率))。默认128MB~~建议物理内存的 50%~80%~~
2. innodb_log_buffer_size: redolog的写缓存。 增大它来减少redolog 刷盘的几率。默认16MB~~建议为16MB ~ 64MB~~
3. 查询缓存：`query_cache`相关参数，把select查询语句的结果缓存下来，下一次查询时直接拿出，如果中间有增删改操作就会清空缓冲区，适合查询频繁的时候用  
4. thread_cache_size: 线程池大小（线程数量）[配置10左右]
5. `like %connect%` 或 `like %timeout%`：并发连接数量[2000左右]或超时时间(超时未通信的连接会断开)
# 日志类型
1. 错误日志
	- MySQLD服务运行过程中出现的error exception coredump
2. 查询日志
	- 所有SQL，增删改查
3. 二进制日志
	- 数据恢复、主从复制
4. 慢查询日志

- redo log和undo log是由InnoDB存储引擎生成的。而binlog是由MySQL Server生成。
# 参数
如果在set设置，只是在当前session设置了  

- log_error= 错误日志
- log_bin=  二进制日志
- log= 查询日志(所有sql)
- log-slow-queries= 慢查询日志
- log-update  更新日志


```mysql
show variables like 'log%';
mysql> show variables like 'log%' \G
*************************** 1. row ***************************
Variable_name: log_bin  二进制日志
        Value: OFF
*************************** 2. row ***************************
Variable_name: log_bin_basename
        Value: 
*************************** 3. row ***************************
Variable_name: log_bin_index
        Value: 
*************************** 4. row ***************************
Variable_name: log_bin_trust_function_creators
        Value: OFF
*************************** 5. row ***************************
Variable_name: log_bin_use_v1_row_events
        Value: OFF
*************************** 6. row ***************************
Variable_name: log_builtin_as_identified_by_password
        Value: OFF
*************************** 7. row ***************************
Variable_name: log_error 错误日志
        Value: /var/log/mysql/error.log
*************************** 8. row ***************************
Variable_name: log_error_verbosity
        Value: 3
*************************** 9. row ***************************
Variable_name: log_output
        Value: FILE
*************************** 10. row ***************************
Variable_name: log_queries_not_using_indexes
        Value: OFF
*************************** 11. row ***************************
Variable_name: log_slave_updates
        Value: OFF
*************************** 12. row ***************************
Variable_name: log_slow_admin_statements
        Value: OFF
*************************** 13. row ***************************
Variable_name: log_slow_slave_statements
        Value: OFF
*************************** 14. row ***************************
Variable_name: log_statements_unsafe_for_binlog
        Value: ON
*************************** 15. row ***************************
Variable_name: log_syslog
        Value: OFF
*************************** 16. row ***************************
Variable_name: log_syslog_facility
        Value: daemon
*************************** 17. row ***************************
Variable_name: log_syslog_include_pid
        Value: ON
*************************** 18. row ***************************
Variable_name: log_syslog_tag
        Value: 
*************************** 19. row ***************************
Variable_name: log_throttle_queries_not_using_indexes
        Value: 0
*************************** 20. row ***************************
Variable_name: log_timestamps
        Value: SYSTEM
*************************** 21. row ***************************
Variable_name: log_warnings
        Value: 2

```
## 配置日志相关
```shell
root@db211:/home/ly# cat /etc/mysql/mysql.conf.d/mysqld.cnf 
# Copyright (c) 2014, 2016, Oracle and/or its affiliates. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 2.0,
# as published by the Free Software Foundation.
#
# This program is also distributed with certain software (including
# but not limited to OpenSSL) that is licensed under separate terms,
# as designated in a particular file or component or in included license
# documentation.  The authors of MySQL hereby grant you an additional
# permission to link the program and your derivative works with the
# separately licensed software that they have included with MySQL.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License, version 2.0, for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

#
# The MySQL  Server configuration file.
#
# For explanations see
# http://dev.mysql.com/doc/mysql/en/server-system-variables.html

[mysqld]
pid-file	= /var/run/mysqld/mysqld.pid
socket		= /var/run/mysqld/mysqld.sock
datadir		= /var/lib/mysql
log-error	= /var/log/mysql/error.log
# By default we only accept connections from localhost
#bind-address	= 127.0.0.1
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
#------lyadd-------
character-set-server=utf8
default-storage-engine=INNODB
log_timestamps=SYSTEM
# 如果没有指定路径，会默认到datadir下
server-id=1
expire_logs_days=7
log-bin=mysql-bin
binlog_format=MIXED

```
- 在服务器上直接删除binlog日志，会造成MySQL无法启动`[ERROR] Failed to open log [ERROR] Could not open log file [ERROR] Can’t init tc log [ERROR] Aborting`，（且正常情况每次重启mysql后新binlog的position都是154）  ==解决方法==：将已经删除的binlog条目从mysql-bin.index文件中删除，MySQL顺利启动。
- 安全删除binlog日志 `PURGE BINARY LOGS TO 'mysql-bin.000001';`(无法删除运行中的mysql下的binlog日志)
### 慢查询日志
- 明文，可以直接看(binlog不行)
```mysql
root@db211:/home/ly# cat /var/lib/mysql/db211-slow.log 
/usr/sbin/mysqld, Version: 5.7.33 (MySQL Community Server (GPL)). started with:
Tcp port: 3306  Unix socket: /var/run/mysqld/mysqld.sock
Time                 Id Command    Argument
# Time: 2025-03-21T04:49:56.308214Z
# User@Host: root[root] @ localhost []  Id:    22
# Query_time: 0.027501  Lock_time: 0.000000 Rows_sent: 0  Rows_examined: 0
use test;
SET timestamp=1742532596;
set global slow_query_log=ON;
# Time: 2025-03-21T04:52:55.935025Z
# User@Host: root[root] @ localhost []  Id:    22
# Query_time: 0.920988  Lock_time: 0.000147 Rows_sent: 1  Rows_examined: 1000001
SET timestamp=1742532775;
select * from t_user limit 1000000,1;
# Time: 2025-03-21T04:55:30.781012Z
# User@Host: root[root] @ localhost []  Id:    22
# Query_time: 1.078875  Lock_time: 0.000248 Rows_sent: 1  Rows_examined: 2000000
SET timestamp=1742532930;
select * from t_user where password = 'h4HcxZKBNQ';
/usr/sbin/mysqld, Version: 5.7.33 (MySQL Community Server (GPL)). started with:
Tcp port: 3306  Unix socket: /var/run/mysqld/mysqld.sock
Time                 Id Command    Argument
# Time: 2025-03-21T13:15:30.606444+08:00
# User@Host: root[root] @ localhost []  Id:     5
# Query_time: 0.653208  Lock_time: 0.000121 Rows_sent: 1  Rows_examined: 2000000
use test;
SET timestamp=1742534130;
select * from t_user where password='MrBmIH6F7l';
# Time: 2025-03-21T16:25:03.888312+08:00
# User@Host: root[root] @ localhost []  Id:     5
# Query_time: 0.658706  Lock_time: 0.000188 Rows_sent: 0  Rows_examined: 2000000
SET timestamp=1742545503;
select * from t_user where email='1200000';
# Time: 2025-03-22T11:33:18.457417+08:00
# User@Host: root[root] @ localhost []  Id:     7
# Query_time: 0.012809  Lock_time: 0.001626 Rows_sent: 0  Rows_examined: 1
SET timestamp=1742614398;
delete from user where id = 3;
```

# binlog
## 开启binlog

```mysql
mysql> show binary logs;#或者show master logs;
+------------------+-----------+
| Log_name         | File_size |
+------------------+-----------+
| mysql-bin.000001 |       177 |
| mysql-bin.000002 |       154 |
+------------------+-----------+
2 rows in set (0.00 sec)
mysql> show variables like '%log_bin%';
+---------------------------------+--------------------------------+
| Variable_name                   | Value                          |
+---------------------------------+--------------------------------+
| log_bin                         | ON                             |
| log_bin_basename                | /var/lib/mysql/mysql-bin       |
| log_bin_index                   | /var/lib/mysql/mysql-bin.index |
| log_bin_trust_function_creators | OFF                            |
| log_bin_use_v1_row_events       | OFF                            |
| sql_log_bin                     | ON                             |
+---------------------------------+--------------------------------+
root@db211:/var/lib/mysql# ls
auto.cnf	 mysql-bin.000001
ca-key.pem	 mysql-bin.000002
ca.pem		 mysql-bin.index
client-cert.pem  performance_schema
client-key.pem	 private_key.pem
db211-slow.log	 public_key.pem
ib_buffer_pool	 server-cert.pem
ibdata1		 server-key.pem
ib_logfile0	 sys
ib_logfile1	 test
ibtmp1		 xx
mysql
mysql> flush logs;
# 对于binlog来说，用来创建新日志文件：关闭当前活动的二进制日志文件（如 mysql-bin.000003），并立即创建一个新文件（如 mysql-bin.000004）。用途：手动触发日志轮转，避免单个文件过大，或在备份前归档当前日志。
# 实际上当服务器在重启时，也会调用flush logs操作,并生成新的binlog日志。
mysql> sudo systemctl restart mysql
mysql> show binary logs;
+------------------+-----------+
| Log_name         | File_size |
+------------------+-----------+
| mysql-bin.000001 |       177 |
| mysql-bin.000002 |       177 |
| mysql-bin.000003 |       154 |
+------------------+-----------+
#操作一些数据
mysql> insert into user(age,name,sex) values(30,'er_wang','W');
mysql> update user set name = 'xxx' where id = 10;
mysql> select * from user;
+----+-----+----------+------+
| id | age | name     | sex  |
+----+-----+----------+------+
|  1 |  22 | zhangsan | W    |
|  3 |  33 | lisi     | M    |
| 10 |  20 | xxx      | W    |
| 15 |  25 | lix      | M    |
| 16 |  30 | er_wang  | W    |
+----+-----+----------+------+
mysql> show binary logs;
+------------------+-----------+
| Log_name         | File_size |
+------------------+-----------+
| mysql-bin.000001 |       177 |
| mysql-bin.000002 |       177 |
| mysql-bin.000003 |       781 |
+------------------+-----------+
myysql> system sudo ls -l /var/lib/mysql 
-rw-r----- 1 mysql mysql       177 Mar 25 23:01 mysql-bin.000001
-rw-r----- 1 mysql mysql       177 Mar 25 23:08 mysql-bin.000002
-rw-r----- 1 mysql mysql       781 Mar 25 23:22 mysql-bin.000003 
```
通过工具查看binlog日志  
``` shell
root@db211:/var/lib/mysql# mysqlbinlog --no-defaults --database=test --base64-output=decode-rows --start-datetime='2025-03-26 00:00:00' --stop-datetime='2025-03-26 23:59:59' mysql-bin.000003 | cat
WARNING: The option --database has been used. It may filter parts of transactions, but will include the GTIDs in any case. If you want to exclude or include transactions, you should use the options --exclude-gtids or --include-gtids, respectively, instead.
/*!50530 SET @@SESSION.PSEUDO_SLAVE_MODE=1*/;
/*!50003 SET @OLD_COMPLETION_TYPE=@@COMPLETION_TYPE,COMPLETION_TYPE=0*/;
DELIMITER /*!*/;
# at 4
#250326  0:15:49 server id 1  end_log_pos 123 CRC32 0x04bed00b 	Start: binlog v 4, server v 5.7.33-log created 250326  0:15:49 at startup
# Warning: this binlog is either in use or was not closed properly.
ROLLBACK/*!*/;
# at 123
#250326  0:15:49 server id 1  end_log_pos 154 CRC32 0xdfd5febc 	Previous-GTIDs
# [empty]
# at 154
#250326  0:17:01 server id 1  end_log_pos 219 CRC32 0xcf2c541e 	Anonymous_GTID	last_committed=0	sequence_number=1   rbr_only=no
SET @@SESSION.GTID_NEXT= 'ANONYMOUS'/*!*/;
# at 219
#250326  0:17:01 server id 1  end_log_pos 298 CRC32 0xbdded0d1 	Query	thread_id=2	exec_time=0	error_code=0
SET TIMESTAMP=1742919421/*!*/;
SET @@session.pseudo_thread_id=2/*!*/;
SET @@session.foreign_key_checks=1, @@session.sql_auto_is_null=0, @@session.unique_checks=1, @@session.autocommit=1/*!*/;
SET @@session.sql_mode=1436549152/*!*/;
SET @@session.auto_increment_increment=1, @@session.auto_increment_offset=1/*!*/;
/*!\C utf8 *//*!*/;
SET @@session.character_set_client=33,@@session.collation_connection=33,@@session.collation_server=33/*!*/;
SET @@session.lc_time_names=0/*!*/;
SET @@session.collation_database=DEFAULT/*!*/;
BEGIN
/*!*/;
# at 298
# at 330
#250326  0:17:01 server id 1  end_log_pos 330 CRC32 0x30d5c44b 	Intvar
SET INSERT_ID=16/*!*/;
#250326  0:17:01 server id 1  end_log_pos 459 CRC32 0x5e444be0 	Query	thread_id=2	exec_time=0	error_code=0
use `test`/*!*/;
SET TIMESTAMP=1742919421/*!*/;
#======================ly: 插入了数据=================
insert into user(age,name,sex) values(30,'er_wang','W')
/*!*/;
# at 459
#250326  0:17:01 server id 1  end_log_pos 490 CRC32 0xab6b62be 	Xid = 17
COMMIT/*!*/;
# at 490
#250326  0:17:14 server id 1  end_log_pos 555 CRC32 0x773bc5e1 	Anonymous_GTID	last_committed=1	sequence_number=2   rbr_only=no
SET @@SESSION.GTID_NEXT= 'ANONYMOUS'/*!*/;
# at 555
#250326  0:17:14 server id 1  end_log_pos 634 CRC32 0xd25d946a 	Query	thread_id=2	exec_time=0	error_code=0
SET TIMESTAMP=1742919434/*!*/;
BEGIN
/*!*/;
# at 634
#250326  0:17:14 server id 1  end_log_pos 750 CRC32 0xb0fee72b 	Query	thread_id=2	exec_time=0	error_code=0
SET TIMESTAMP=1742919434/*!*/;
#======================ly: 更新了数据=================
update user set name = 'xxx' where id = 10
/*!*/;
# at 750
#250326  0:17:14 server id 1  end_log_pos 781 CRC32 0xc41bfc8d 	Xid = 18
COMMIT/*!*/;
SET @@SESSION.GTID_NEXT= 'AUTOMATIC' /* added by mysqlbinlog */ /*!*/;
DELIMITER ;
# End of log file
/*!50003 SET COMPLETION_TYPE=@OLD_COMPLETION_TYPE*/;
/*!50530 SET @@SESSION.PSEUDO_SLAVE_MODE=0*/;
```
## 三种binlog_format
- row模式---test_row数据库--mysql-bin.000006(数据最大)
	- 记录每行数据的变化（修改前/后的完整行数据）
	- mysqlbinlog --base64-output选项就是针对这个模式的
		- ATTO(默认)。输出内容：原始BASE64字符串。可读性：低。适用场景：数据重放、原始日志保存。
		- NEVER。输出内容：==过滤BASE64块==，保留元信息。可读性：中。适用场景：快速查看日志结构。
		- DECODE-ROWS -v。输出内容：==伪SQL注释（带字段详情）==。可读性：高。适用场景：人工分析、审计。
- statement模式---test_statement数据库--mysql-bin.000007(数据最小)~~如果修改了1000条数据，也许这个模式只要一条sql，而row则需要记录1000行所有数据前后变动~~
	- 只记录修改数据的 SQL
- mixed模式---test_mixed数据库--mysql-bin.000008(最终1303字节，中等)
	- 默认使用 STATEMENT 格式
	- 对可能引起不一致的语句自动切换为 ROW 格式
	- 有一些例外的情况，比如now()
```mysql
#mix下的binlog日志--部分摘取
SET TIMESTAMP=1742960957/*!*/;
SET @@session.time_zone='SYSTEM'/*!*/;
BEGIN
/*!*/;
# at 1272
# at 1304
#250326 11:49:17 server id 1  end_log_pos 1304 CRC32 0x53ecd13f 	Intvar
SET INSERT_ID=2/*!*/;
#250326 11:49:17 server id 1  end_log_pos 1447 CRC32 0x93409ee9 	Query	thread_id=2	exec_time=0	error_code=0
##使用了SET TIMESTAMP语句，使得下面的now()都会以这个时间为准，转化后是2025-03-26 11:49:17
SET TIMESTAMP=1742960957/*!*/;
insert into stu(birth,name) values(now(),'hello')
/*!*/;
#======ly事件开始于1447，结束于1478======
# at 1447
#250326 11:49:17 server id 1  end_log_pos 1478 CRC32 0x2e1f6111 	Xid = 83
COMMIT/*!*/;
```
分别以三种模式记录sql变动到binlog日志中
```mysql
#查看当前binlog文件
mysql> show binary logs;
+------------------+-----------+
| Log_name         | File_size |
+------------------+-----------+
| mysql-bin.000005 |       154 |
+------------------+-----------+
mysql> flush logs; 
mysql> show binary logs;
+------------------+-----------+
| Log_name         | File_size |
+------------------+-----------+
| mysql-bin.000005 |       201 |
| mysql-bin.000006 |       154 |
+------------------+-----------+
#即将使用 mysql-bin.000006
set binlog_format=ROW;#set binlog_format=STATEMENT;#set binlog_format=MIXED;
mysql> select @@binlog_format;
+-----------------+
| @@binlog_format |
+-----------------+
| ROW             |
+-----------------+

#数据库测试语句
create database test_row;#create database test_statement;#create database test_mixed;
use test_row;#use test_statement;#use test_mixed;
create table stu(id int auto_increment, birth datetime, name varchar(20), primary key(id));
#重启mysql或者使用新的binlog日志 
#sudo systemctl restart mysql; #flush logs;
#即将使用mysql-bin.000004(随机的，我这里是04)
#插入两条语句
insert into stu(birth,name) values('1990-10-02','hello');
insert into stu(birth,name) values(now(),'hello');
mysql> show binary logs;
#binlog文件变大了
+------------------+-----------+
| Log_name         | File_size |
+------------------+-----------+
| mysql-bin.000005 |       201 |
| mysql-bin.000006 |      1126 |
+------------------+-----------+
mysqlbinlog --no-defaults  --base64-output=DECODE-ROWS -v mysql-bin.000006 | cat
```
# MySQL数据备份恢复
## 备份
全量备份+增量备份  
```mysql
#!/bin/bash
# 文件名:backup.sh
# 全量备份+Binlog备份脚本
#.
#├── backup.sh
#└── mysql
#    ├── binlog
#    │   └── binlog_backup_mysql-bin.000002  (增量日志binlog，即开始执行全量备份后->执行全量备份结束--这段时间内的数据增删改)
#    ├── full
#    │   └── full_backup_20250326.sql (mysqldump执行全量备份)
#    └── mysql_backup.log (备份过程中的日志)

func(){

BACKUP_DIR="/home/ly/backup/mysql"
DATE=$(date +%Y%m%d)
LOG_FILE="/home/ly/backup/mysql/mysql_backup.log"

# 创建备份目录
mkdir -p $BACKUP_DIR/full $BACKUP_DIR/binlog
echo "" > LOG_FILE


# 1. 执行全量备份
echo "$(date) - 开始全量备份" >> $LOG_FILE
mysqldump -u root -phello.root --single-transaction --master-data=2 --flush-logs --all-databases > $BACKUP_DIR/full/full_backup_$DATE.sql 2>> $LOG_FILE
#这行mysqldump命令执行后，会马上执行flush-logs，生成新binlog-new。之后所有的增删改都在binlog-new上，且不会在全量备份中


# 2. 备份Binlog(新binlog-new)
echo "$(date) - 开始Binlog备份" >> $LOG_FILE
# 获取全量备份时的Binlog位置
BINLOG_FILE=$(grep "CHANGE MASTER TO MASTER_LOG_FILE=" $BACKUP_DIR/full/full_backup_$DATE.sql | awk -F"'" '{print $2}' )
BINLOG_POS=$(grep "CHANGE MASTER TO MASTER_LOG_FILE="  $BACKUP_DIR/full/full_backup_$DATE.sql  | awk -F"=" '{print $3}'| tr -d ";") 
echo $BINLOG_FILE
echo $BINLOG_POS 

# 备份从该位置之后的所有Binlog
# --stop-never,备份是实时的，开始备份后binlog可以继续写入
mysqlbinlog --read-from-remote-server --stop-never --host=192.168.1.211 --user=ly --password=hello.ly --raw --start-position=$BINLOG_POS $BINLOG_FILE --result-file=$BACKUP_DIR/binlog/binlog_backup_  2>> $LOG_FILE #& 

echo "$(date) - 备份完成" >> $LOG_FILE

}
func

```
`full_backup_$DATE.sql`中有一句话`CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000002', MASTER_LOG_POS=154;`其中`MASTER_LOG_FILE`表示备份时正在使用的二进制日志文件名，而`MASTER_LOG_POS`表示备份时二进制日志的精确位置(字节偏移量)。增量日志正是根据这个信息，来备份增量数据。154是Binlog 文件头的(常见)固定开销
## 数据恢复演示
```mysql
#建库建表
CREATE DATABASE lytest;
CREATE TABLE `lyuser` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `age` tinyint(4) NOT NULL,
  `name` varchar(20) DEFAULT NULL,
  `sex` enum('M','W') DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_name` (`name`),
  KEY `idx_age` (`age`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;
##这里用navicat生成了几条默认数据，由于名字带空格，就删除了重新插入
delete from lyuser;
#添加数据
INSERT INTO `lytest`.`lyuser` (`id`, `age`, `name`, `sex`) VALUES (17, 46, 'QianXiuying', 'W');
INSERT INTO `lytest`.`lyuser` (`id`, `age`, `name`, `sex`) VALUES (18, 16, 'DuLu', 'W');
INSERT INTO `lytest`.`lyuser` (`id`, `age`, `name`, `sex`) VALUES (19, 39, 'MoJialun', 'W');
INSERT INTO `lytest`.`lyuser` (`id`, `age`, `name`, `sex`) VALUES (20, 39, 'TianLu', 'W');
INSERT INTO `lytest`.`lyuser` (`id`, `age`, `name`, `sex`) VALUES (21, 38, 'LiYunxi', 'M');
#做个update测试
ysql> update lyuser set name='chenchen' where id = 20;
mysql> select * from lyuser;
+----+-----+-------------+------+
| id | age | name        | sex  |
+----+-----+-------------+------+
| 17 |  46 | QianXiuying | W    |
| 18 |  16 | DuLu        | W    |
| 19 |  39 | MoJialun    | W    |
| 20 |  39 | chenchen    | W    |
| 21 |  38 | LiYunxi     | M    |
+----+-----+-------------+------+
##查看一下，只要过程中不重启mysql，刚才所有的操作应该都在最后一个日志上
mysql> show binary logs;
+------------------+-----------+
| Log_name         | File_size |
+------------------+-----------+
| mysql-bin.000001 |       177 |
| mysql-bin.000002 |       177 |
| mysql-bin.000003 |      4477 |
+------------------+-----------+
#此时删除数据库
mysql> drop database lytest;
mysql> show databases;
#已经没有lytest库了
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test               |
| xx                 |
+--------------------+
6 rows in set (0.00 sec)
#再次确认一下，发现binlog磁盘文件存在，且修改日期正确
root@db211:/var/lib/mysql# ls -l | grep 00000
-rw-r----- 1 mysql mysql       177 Mar 26 00:15 mysql-bin.000001
-rw-r----- 1 mysql mysql       177 Mar 26 00:15 mysql-bin.000002
-rw-r----- 1 mysql mysql      4640 Mar 26 07:58 mysql-bin.000003
#=================================================
#=================================================
#也可以先导出为sql文件，再查看数据并导出
root@db211:/var/lib/mysql# mysqlbinlog mysql-bin.000003 > recover.sql;
root@db211:/var/lib/mysql# ls -l | grep reco
-rw-r--r-- 1 root  root      10568 Mar 26 08:10 recover.sql
```
- 利用binlog恢复数据的过程中，这些操作会再次记录到(新)binlog中
- `delete from yy` 和 `drop database xx` 都会被记录
- 实际操作中得知道库从何时建立，在哪个binlog文件中
- 过期问题
	- 关于`expire_logs_days`: 当满足以下条件时，Binlog文件会被自动删除：`当前时间 - 文件最后修改时间 > expire_logs_days`
	- 当前活动的 Binlog 文件（正在写入的日志）即使因为 expire_logs_days 设置的时间到期且长时间没有写入，也不会被自动清理，除非触发日志轮换`（如执行 FLUSH LOGS 或 Binlog 文件大小达到 max_binlog_size`）或服务重启创建新binlog，而旧的成为了非活动文件，会立即清理，所以该在日志轮换前备份日志文件。
	- 在执行FLUSH LOGS前备份当前活动的 Binlog 文件，如果备份后有数据写入，是否会导致数据丢失？1. 锁定写入 + 备份(推荐) 2.基于 Binlog 位置增量备份 3. 使用 mysqlbinlog 实时备份  
```mysql
# 备份当前 Binlog 并持续跟踪新事件
mysqlbinlog --read-from-remote-server --host=localhost --user=root --password \
  --raw --stop-never binlog.000010 --result-file=/backup/backup_
```
- 如何备份binglog日志呢
```mysql
1. 定时任务调用 FLUSH LOGS
-- 通过事件调度器每24小时轮换一次
CREATE EVENT rotate_binlog_hourly
ON SCHEDULE EVERY 24 HOUR
DO FLUSH LOGS;
2. 结合expire_logs_days 自动清理
SET GLOBAL expire_logs_days = 7;  -- 保留最近7天的日志
假设1操作产生了a01,b02,c03,d04；只要在a01七天内备份了日志就行
#也可以使用shell脚本定时备份,该语句将binlog日志转为sql脚本文件
mysqlbinlog --base64-output=DECODE-ROWS -v /var/lib/mysql/binlog.000001 > ~/binlog_export.sql
```
- 数据恢复主要靠以往备份的数据(sql脚本)+当前binlog文件
