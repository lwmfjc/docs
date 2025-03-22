---
title: 04事务
description: 04事务
categories:
  - 学习
tags:
  - 施磊
  - MySQL高级
date: 2025-03-21T16:28:40+08:00
lastmod: 2025-03-21T16:28:40+08:00
cssAttach:
  - book01
cssclasses:
  - book01
---
# 关闭自动提交

>在MySQL命令行的默认设置下，事务都是自动提交的，即执行SQL语句后就会马上执行COMMIT操作。因此开始一个事务，必须使用BEGIN、START TRANSACTION，(显示开启事务）或者执行SET AUTOCOMMIT=0，以禁用当前会话的自动提交。

1. select语句一般用来输出用户变量，比如select @变量名，用于输出数据源不是表格的数据。
2. 系统变量在变量名前面有==两个@==  

```mysql
mysql> show variables like 'autocommit';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| autocommit    | ON    |
+---------------+-------+
1 row in set (0.00 sec)

mysql> select @@autocommit;
+--------------+
| @@autocommit |
+--------------+
|            1 |
+--------------+
1 row in set (0.00 sec)
# 修改变量
set autocommit=0;
```
# 事务并发存在的问题
【隔离性】脏读（读到了还没有提交的数据）  

【隔离性】不可重复读（同一事务中，第1次读的数据和第2次读的数据不一样。读到了事务操作过程中其他事务提交的数据，也不应该，这个没法保证一致性。比如我第一次根据某个事务做了一个操作，第二次想同样的逻辑做一个判断操作，但是数据变了，导致同一个事务中对同一个(其实不是了）数据做的操作居然不一致  
	
【隔离性】虚读、幻读（同一事务中：我第一次读到某一条数据，但是第二次没读到；或者第一次没读到，第二次居然读到了。条数问题）
# 事务的隔离级别
READ_UNCOMMITTED  读未提交  
READ_COMMITTED  读已提交  
REPEATABLE_READ  重复读
SERIALIZABLE 串行化
修改事务隔离级别：  
```mysql
set tx_isolation='SERIALIZABLE'; (可以加global，让新开的session也使用该事务隔离级别)
```