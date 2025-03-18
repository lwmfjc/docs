---
title: 02增删改查
description: 02增删改查
categories:
  - 学习
tags:
  - 施磊
  - MySQL高级
date: 2025-03-16T17:04:04+08:00
lastmod: 2025-03-16T17:04:04+08:00
cssAttach:
  - book01
cssclasses:
  - book01
---
# 分类
- DDL 数据定义语言(create,drop,alter)
- DML 数据操纵语言(insert,delete,update,select)
- DCL 数据控制语言(grant,revoke)
# 删除
``` mysql
mysql> select * from user;
+----+----------+-----+-----+
| id | name     | age | sex |
+----+----------+-----+-----+
|  1 | zhangsan |  20 | M   |
|  2 | wuqi     |  34 | M   |
|  5 | baobaoi  |  45 | W   |
|  6 | lalal    |  44 | W   |
+----+----------+-----+-----+
4 rows in set (0.00 sec)
mysql> delete from user where id = 6
#如果之后重启了mysql，则再插入的数据id为6；如果没有重启，则再插入的数据id为7
mysql> nsert into user(name,age,sex) values('hah',35,'W');
```
# 新增
一次新增多条数据和多次新增单条数据区别  
![](img/ly-20250316181803420.png)

# 搜索
limit可以优化sql语句，不过要看数据的位置  
```mysql 
mysql> select * from t_user  limit 1999999 ,1;
+---------+------------------+------------+
| id      | email            | password   |
+---------+------------------+------------+
| 2000000 | cwng78@yahoo.com | h4HcxZKBNQ |
+---------+------------------+------------+
1 row in set (0.52 sec)
#这条数据在最后一条，所以优化效果不怎么样
mysql> select * from t_user where email='cwng78@yahoo.com';
+---------+------------------+------------+
| id      | email            | password   |
+---------+------------------+------------+
| 2000000 | cwng78@yahoo.com | h4HcxZKBNQ |
+---------+------------------+------------+
1 row in set (0.47 sec)
```
在第一条或者前面，则优化效果显著  
```mysql
mysql> select * from t_user  limit 0 ,1;
+----+------------------------+------------+
| id | email                  | password   |
+----+------------------------+------------+
|  1 | randyhill201@gmail.com | U5ivlQVd9A |
+----+------------------------+------------+
1 row in set (0.00 sec)

mysql> select * from t_user  where email = 'randyhill201@gmail.com';
+----+------------------------+------------+
| id | email                  | password   |
+----+------------------------+------------+
|  1 | randyhill201@gmail.com | U5ivlQVd9A |
+----+------------------------+------------+
1 row in set (0.55 sec)

mysql> select * from t_user  where email = 'randyhill201@gmail.com' limit 1;
+----+------------------------+------------+
| id | email                  | password   |
+----+------------------------+------------+
|  1 | randyhill201@gmail.com | U5ivlQVd9A |
+----+------------------------+------------+
1 row in set (0.00 sec)

```
## sql语句优先级顺序
- `语法顺序：select->from->where->group by->having->order by -> limit`  
`执行顺序：from --> where -- > group by --> having --> select --> order by --> limit`
- explain不解释mysql优化后的操作
# limit优化
利用索引在分页中的优化(不过得id是连续且没有删除过的)
```mysql
mysql> select * from t_user where id > 1000000 limit 0,20;
+---------+-------------------------+------------+
| id      | email                   | password   |
+---------+-------------------------+------------+
| 1000001 | amy@outlook.com         | n5zMIHnqrC |
| 1000002 | ssugiy@gmail.com        | LEmEgFfejT |
| 1000003 | nanko@mail.com          | rVQXFYIDeF |
| 1000004 | sitsy9@mail.com         | CF3yJLWgNy |
| 1000005 | mildred412@outlook.com  | JswbqbOTJm |
| 1000006 | fergusonjesus@yahoo.com | ysJU7uvASH |
| 1000007 | ruiwang6@icloud.com     | KWVLOYMWhZ |
| 1000008 | bradlryan@hotmail.com   | t2k89OD6DL |
| 1000009 | eitamasuda@icloud.com   | Kf3Bal3tDP |
| 1000010 | eleha@mail.com          | CyTR4Ip5JW |
| 1000011 | chichy@mail.com         | ooo1V8MVe2 |
| 1000012 | linzi@outlook.com       | KOTV9fP4Xs |
| 1000013 | nakayamam@gmail.com     | K4LbwiNPRD |
| 1000014 | zhiyuand9@icloud.com    | 3dqhPhXdGh |
| 1000015 | swl618@gmail.com        | gNEUyvH2Fn |
| 1000016 | takuya2@gmail.com       | KUYing6JwV |
| 1000017 | okwa@icloud.com         | 1UFqbATwQU |
| 1000018 | khi@hotmail.com         | JyZHrHDJz3 |
| 1000019 | simpsonm324@gmail.com   | 2ZOPJJKTyE |
| 1000020 | vherrera1229@mail.com   | 1SWCeRYeLc |
+---------+-------------------------+------------+
20 rows in set (0.00 sec)
mysql> select * from t_user limit 1000000,20;
+---------+-------------------------+------------+
| id      | email                   | password   |
+---------+-------------------------+------------+
| 1000001 | amy@outlook.com         | n5zMIHnqrC |
| 1000002 | ssugiy@gmail.com        | LEmEgFfejT |
| 1000003 | nanko@mail.com          | rVQXFYIDeF |
| 1000004 | sitsy9@mail.com         | CF3yJLWgNy |
| 1000005 | mildred412@outlook.com  | JswbqbOTJm |
| 1000006 | fergusonjesus@yahoo.com | ysJU7uvASH |
| 1000007 | ruiwang6@icloud.com     | KWVLOYMWhZ |
| 1000008 | bradlryan@hotmail.com   | t2k89OD6DL |
| 1000009 | eitamasuda@icloud.com   | Kf3Bal3tDP |
| 1000010 | eleha@mail.com          | CyTR4Ip5JW |
| 1000011 | chichy@mail.com         | ooo1V8MVe2 |
| 1000012 | linzi@outlook.com       | KOTV9fP4Xs |
| 1000013 | nakayamam@gmail.com     | K4LbwiNPRD |
| 1000014 | zhiyuand9@icloud.com    | 3dqhPhXdGh |
| 1000015 | swl618@gmail.com        | gNEUyvH2Fn |
| 1000016 | takuya2@gmail.com       | KUYing6JwV |
| 1000017 | okwa@icloud.com         | 1UFqbATwQU |
| 1000018 | khi@hotmail.com         | JyZHrHDJz3 |
| 1000019 | simpsonm324@gmail.com   | 2ZOPJJKTyE |
| 1000020 | vherrera1229@mail.com   | 1SWCeRYeLc |
+---------+-------------------------+------------+
20 rows in set (0.43 sec)

```
 (Extra: Using filesort，外排序，不一定涉及磁盘io)  
~~Using filesort仅仅表示没有使用索引的排序，事实上filesort这个名字很糟糕，并不意味着在硬盘上排序，filesort与文件无关。因此消除Using filesort的方法就是让查询sql的排序走索引。它跟文件没有任何关系，实际上是内部的一个快速排序~~

```mysql
mysql> desc user \G;
*************************** 1. row ***************************
  Field: id
   Type: int(10) unsigned
   Null: NO
    Key: PRI
Default: NULL
  Extra: auto_increment
*************************** 2. row ***************************
  Field: name
   Type: varchar(50)
   Null: NO
    Key: UNI（唯一索引）
Default: NULL
  Extra: 
*************************** 3. row ***************************
  Field: age
   Type: tinyint(4)
   Null: NO
    Key: 
Default: NULL
  Extra: 
*************************** 4. row ***************************
  Field: sex
   Type: enum('M','W')
   Null: NO
    Key: 
Default: NULL
  Extra: 
4 rows in set (0.00 sec)

mysql> explain select * from user order by age \G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: user
   partitions: NULL
         type: ALL
possible_keys: NULL
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 20
     filtered: 100.00
        Extra: Using filesort
1 row in set, 1 warning (0.00 sec)
```
优化(select影响是否回表，是否使用索引)  
```mysql
mysql> explain select name from user order by name \G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: user
   partitions: NULL
         type: index
possible_keys: NULL
          key: name
      key_len: 152
          ref: NULL
         rows: 20
     filtered: 100.00
        Extra: Using index
```
## 何为N路归并排序
![](img/ly-20250317145636919.png)
![](img/ly-20250317145644139.png)  
假设磁盘文件有900MB的数据需要排序，而电脑剩余内存只有100MB。
- 首先把磁盘分为 900/100=9份，第1份放到内存应用排序算法排序后放回磁盘，然后第2，3...9份。这就得到9份有序的数据
- 把内存文件分为100/(9+1)=10份，多出来一份为缓冲区  
![](img/ly-20250317145925031.png)  
- 从原来的900MB数据的前10MB取出数据分别放到内存文件的那9个位置中（最后一个缓冲）  
![](img/ly-20250317150102548.png)  
这时候就可以用上归并排序了
- 从前9份中对比，最小放到缓冲区（蓝色区）中，缓冲区满了后输出到临时文件中（另一份），如果前9份区空了则再从对应的100MB中取数据过来
- 最后临时文件就是排好序的900MB数据
# 多表联合查询
## inner join
1. 在内连接中，on子句和where子句是等价的
2. ON子句是专门为“外连接驱动表中的记录在被驱动表找不到匹配记录时是否把改驱动表记录加入结果集中”这个场景提出的。如果把ON子句放到内连接中，MySQL会把它像WHERE子句一样对待
## 原理
《MySQL是如何运行的》提出根本原因：
- ~~MySQL中连接查询采用的是嵌套循环连接算法，驱动表会被访问一次，被驱动表可能被访问多次，所以两表查询的成本由两部分构成：1. 单次查询驱动表的成本 2. 多次查询被驱动表的成本（具体查询多少次取决于针对驱动表查询后的结果集中有多少条记录。 我们把查询驱动表后得到的记录条数称为驱动表的扇出~~  
- ~~因此，驱动表扇出值越小，对被驱动表的查询次数也就越少,连接查询的总成本就越低。~~
本书得出的结论是：
`成本= 单次查询驱动表的成本+驱动表的扇出 x (带条件)访问被驱动表的成本`，所以要~~尽量在被驱动表的连接列上建立索引~~，这样就可以使用ref访问方法来降低`被驱动表的访问成本`。
下图中，如果没有where语句，a作为驱动表时成本为a+ax1,c作为驱动表时成本是c+ cx1 。~~因为a和c都给uid建了索引~~所以a还是c作为驱动表取决于a数据量少还是c数据量少。 
![](img/ly-20250317184912482.png)  
带了where语句，a作为驱动表时成本为a+ax1,c作为驱动表时成本是1+ 1x1。我觉得这里MySQL会把c作为驱动表才对。 
==考虑一下，如果没有where条件且a.uid和c.uid都没有被作为索引呢？==
比如select * from student a inner join exame c on a.uid = c.uid
此时，a作为驱动表时成本为a+axc,c作为驱动表时成本是c+ cxa，这个时候便会得出~~数据量少的作为被驱动表~~这个结论(视频中提出的)
## left join 妙用取最大值  
```mysql
#将e1左连接e2
#在e2中查找和e1同cid(课程名)的数据，且e2.score>e1.score (left join同一个表，也就是在本表中查找score数据比他小的数据，如果没找到(null)，说明这条记录就是最大值)
mysql> select * from exame e1 left join exame e2  on  e1.cid=e2.cid and e1.score < e2.score

where e2.cid is null and e1.cid=2;
+-----+-----+------------+-------+------+------+------+-------+
| uid | cid | time       | score | uid  | cid  | time | score |
+-----+-----+------------+-------+------+------+------+-------+
|   3 |   2 | 2021-04-10 |    93 | NULL | NULL | NULL |  NULL |
+-----+-----+------------+-------+------+------+------+-------+
```
## 利用inner join优化limit语句
```mysql
mysql> select * from t_user limit 1500000,20;
+---------+--------------------------+------------+
| id      | email                    | password   |
+---------+--------------------------+------------+
| 1500001 | kkch@icloud.com          | VMljfFIJT5 |
| 1500002 | yuning2@outlook.com      | VYX1IQ59qt |
| 1500003 | rui61@gmail.com          | 5HnNWjDW0H |
| 1500004 | albonnie@outlook.com     | M3fYmDyoui |
| 1500005 | esthesimpson@yahoo.com   | Okbtyijt8Z |
| 1500006 | wfku@hotmail.com         | ZqFSJkyPqs |
| 1500007 | ake04@gmail.com          | DqjjzxXYDs |
| 1500008 | changlan9@mail.com       | xRjDhUpZiR |
| 1500009 | luo1115@yahoo.com        | WGUfQpKZY3 |
| 1500010 | kart2@yahoo.com          | OETvxdPQtr |
| 1500011 | cwpang1026@gmail.com     | E6cWTO9IVN |
| 1500012 | mitchellhele@outlook.com | ZZPCn7UmYJ |
| 1500013 | fushinglam5@icloud.com   | xofN92D5l9 |
| 1500014 | kamkk2@icloud.com        | XoAdbFjIgY |
| 1500015 | edwajosep@outlook.com    | Blsbc6YkuL |
| 1500016 | mitsuki403@yahoo.com     | Ly1Q8OcVyl |
| 1500017 | yllee2001@hotmail.com    | EBahkbLP5t |
| 1500018 | liksun627@hotmail.com    | NkvdJZMrd8 |
| 1500019 | mewm@icloud.com          | wXjmaPHo2j |
| 1500020 | kaowk@gmail.com          | 7SqSEUTMRS |
+---------+--------------------------+------------+
20 rows in set (0.49 sec)
#利用索引减少查询成本（数据量少，也许能减少磁盘io）。查出id后，innder join联表查询，又利用了聚簇索引查询时间为常量时间的特点
mysql> select * from t_user a inner join (select id from t_user limit 1500000,20) b on a.id =b.id;
+---------+--------------------------+------------+---------+
| id      | email                    | password   | id      |
+---------+--------------------------+------------+---------+
| 1500001 | kkch@icloud.com          | VMljfFIJT5 | 1500001 |
| 1500002 | yuning2@outlook.com      | VYX1IQ59qt | 1500002 |
| 1500003 | rui61@gmail.com          | 5HnNWjDW0H | 1500003 |
| 1500004 | albonnie@outlook.com     | M3fYmDyoui | 1500004 |
| 1500005 | esthesimpson@yahoo.com   | Okbtyijt8Z | 1500005 |
| 1500006 | wfku@hotmail.com         | ZqFSJkyPqs | 1500006 |
| 1500007 | ake04@gmail.com          | DqjjzxXYDs | 1500007 |
| 1500008 | changlan9@mail.com       | xRjDhUpZiR | 1500008 |
| 1500009 | luo1115@yahoo.com        | WGUfQpKZY3 | 1500009 |
| 1500010 | kart2@yahoo.com          | OETvxdPQtr | 1500010 |
| 1500011 | cwpang1026@gmail.com     | E6cWTO9IVN | 1500011 |
| 1500012 | mitchellhele@outlook.com | ZZPCn7UmYJ | 1500012 |
| 1500013 | fushinglam5@icloud.com   | xofN92D5l9 | 1500013 |
| 1500014 | kamkk2@icloud.com        | XoAdbFjIgY | 1500014 |
| 1500015 | edwajosep@outlook.com    | Blsbc6YkuL | 1500015 |
| 1500016 | mitsuki403@yahoo.com     | Ly1Q8OcVyl | 1500016 |
| 1500017 | yllee2001@hotmail.com    | EBahkbLP5t | 1500017 |
| 1500018 | liksun627@hotmail.com    | NkvdJZMrd8 | 1500018 |
| 1500019 | mewm@icloud.com          | wXjmaPHo2j | 1500019 |
| 1500020 | kaowk@gmail.com          | 7SqSEUTMRS | 1500020 |
+---------+--------------------------+------------+---------+
20 rows in set (0.35 sec)
```
# explain
## 前提
```mysql
mysql> select * from student; 
#uid是主键
+-----+----------+-----+-----+
| uid | name     | age | sex |
+-----+----------+-----+-----+
|   1 | zhangsan |  18 | M   |
|   2 | gaoyang  |  20 | W   |
|   3 | chenwei  |  22 | M   |
|   4 | linfeng  |  21 | W   |
|   5 | liuxiang |  19 | W   |
|   7 | weiwie   |  20 | M   |
+-----+----------+-----+-----+
6 rows in set (0.00 sec)

mysql> select * from exame;
#(uid,cid)是联合主键
+-----+-----+------------+-------+
| uid | cid | time       | score |
+-----+-----+------------+-------+
|   1 |   1 | 2021-04-09 |    99 |
|   1 |   2 | 2021-04-10 |    90 |
|   2 |   2 | 2021-04-10 |    90 |
|   2 |   3 | 2021-04-12 |    85 |
|   3 |   1 | 2021-04-09 |    56 |
|   3 |   2 | 2021-04-10 |    93 |
|   3 |   3 | 2021-04-12 |    89 |
|   3 |   4 | 2021-04-11 |   100 |
|   4 |   4 | 2021-04-11 |    99 |
|   5 |   2 | 2021-04-10 |    59 |
|   5 |   3 | 2021-04-12 |    94 |
|   5 |   4 | 2021-04-11 |    95 |
+-----+-----+------------+-------+
12 rows in set (0.00 sec)

```
## inner join
### 例1
```mysql
mysql> explain select a.*,b.* from student a inner join exame b on a.uid=b.uid where b.cid =3 \G;
#联合主键顺序(uid,cid)，所以这里没有用上主键，b=3使用了全表扫描后表记录少，是驱动表。
#之后exame当作被驱动表，用上了索引
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: b
   partitions: NULL
         type: ALL
possible_keys: PRIMARY
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 12
     filtered: 10.00
        Extra: Using where
*************************** 2. row ***************************
           id: 1
  select_type: SIMPLE
        table: a
   partitions: NULL
         type: eq_ref
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 4
          ref: test.b.uid
         rows: 1
     filtered: 100.00
        Extra: NULL
2 rows in set, 1 warning (0.00 sec)
```
### 例2
```mysql  
mysql> explain select a.*,b.* from student a inner join exame b on a.uid=b.uid where b.uid =3 \G;
#联合主键顺序(uid,cid)，所以这里用上主键，b=3使用了索引查询后记录少，是驱动表。
#之后exame当作被驱动表，用上了索引
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: a
   partitions: NULL
         type: const
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 4
          ref: const
         rows: 1
     filtered: 100.00
        Extra: NULL
*************************** 2. row ***************************
           id: 1
  select_type: SIMPLE
        table: b
   partitions: NULL
         type: ref
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 4
          ref: const
         rows: 4
     filtered: 100.00
        Extra: NULL
2 rows in set, 1 warning (0.00 sec)
```
# exists和left join区别
```mysql 
mysql> explain select * from student s where not exists (select 1 from exame e where e.uid=s.uid) \G
*************************** 1. row ***************************
           id: 1
  select_type: PRIMARY
        table: s
   partitions: NULL
         type: ALL
possible_keys: NULL
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 6
     filtered: 100.00
        Extra: Using where
*************************** 2. row ***************************
           id: 2
  select_type: DEPENDENT SUBQUERY
        table: e
   partitions: NULL
         type: ref
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 4
          ref: test.s.uid
         rows: 2
     filtered: 100.00
        Extra: Using index
2 rows in set, 2 warnings (0.00 sec)
#==========================================
mysql> explain select * from student s left join exame e on s.uid=e.uid where e.uid is null \G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: s
   partitions: NULL
         type: ALL
possible_keys: NULL
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 6
     filtered: 100.00
        Extra: NULL
*************************** 2. row ***************************
           id: 1
  select_type: SIMPLE
        table: e
   partitions: NULL
         type: ALL
possible_keys: PRIMARY
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 12
     filtered: 10.00
        Extra: Using where; Not exists; Using join buffer (Block Nested Loop)
2 rows in set, 1 warning (0.00 sec)
```
# not in不走索引？
```mysql 
select * from test where second_key not in(10,30,50);
#-------------------------
 id: 1
  select_type: SIMPLE
        table: test
   partitions: NULL
         type: ALL （不走索引）
possible_keys: idx_second_key
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 8
     filtered: 75.00
        Extra: Using where
1 row in set, 1 warning (0.00 sec) 
```
## 走索引的情形
```mysql
select second_key from test where second_key not in(10,30,50);
  id: 1
  select_type: SIMPLE
        table: test
   partitions: NULL
         type: range(有范围的索引扫描)，因为这里不需要回表，且sql语句被转化了
possible_keys: idx_second_key
          key: idx_second_key
      key_len: 5
          ref: NULL
         rows: 6
     filtered: 100.00
        Extra: Using where; Using index
 
```

```mysql
#相对于select * from test where second_key not in(10,30,50); 这个不走索引
select * from test where second_key not in(10,30,50) limit 3;
#被拆分了select * from test where 
#(second_key < 10) 
#or 
#(second_key > 10 and second_key < 30) 
#or 
#(second_key > 30 and second_key < 50) 
#or 
#(second_key > 50);
#为什么上面不拆分呢？因为判定后觉得代价太大，mysql决定走全表查询
 id: 1
  select_type: SIMPLE
        table: test
   partitions: NULL
         type: range
possible_keys: idx_second_key
          key: idx_second_key
      key_len: 5
          ref: NULL
         rows: 6
     filtered: 100.00
        Extra: Using index condition
```
# 连接示例
## MySQL是怎样连接的
### WHERE子句中的过滤条件
WHERE子句中的过滤条件就是我们平时见的那种，不论是内连接还是外连接，凡是==不符合==WHERE子句中过滤条件的记录都==不会被加入到最后的结果集==
### ON子句中的过滤条件
对于外连接的驱动表中的记录来说，如果无法在被驱动表中找到匹配ON子句中过滤条件的记录，那么该驱动表记录仍然会被加入到结果集中，对应的被驱动表记录的各个字段==使用NULL值填充==~~所以用左连接时，大部分情况where处用is null来找到条件外的数据~~
### 注意
这个 ON 子句是专门为"外连接驱动表中的记录在被驱动表找不到匹配记录时是否应该把该驱动表记录加入结果集中"这个场景提出的。所以，如果把 ON 子句放到内连接中，MySQL会把它像WHERE子句一样对待，也就是说，内连接中的WHERE子句和ON子句是等价的
## 表
```mysql
mysql> select * from student;
+-----+----------+-----+-----+
| uid | name     | age | sex |
+-----+----------+-----+-----+
|   1 | zhangsan |  18 | M   |
|   2 | gaoyang  |  20 | W   |
|   3 | chenwei  |  22 | M   |
|   4 | linfeng  |  21 | W   |
|   5 | liuxiang |  19 | W   |
|   7 | weiwie   |  20 | M   |
+-----+----------+-----+-----+
6 rows in set (0.00 sec)
#============================
mysql> select * from exame;
+-----+-----+------------+-------+
| uid | cid | time       | score |
+-----+-----+------------+-------+
|   1 |   1 | 2021-04-09 |    99 |
|   1 |   2 | 2021-04-10 |    90 |
|   2 |   2 | 2021-04-10 |    90 |
|   2 |   3 | 2021-04-12 |    85 |
|   3 |   1 | 2021-04-09 |    56 |
|   3 |   2 | 2021-04-10 |    93 |
|   3 |   3 | 2021-04-12 |    89 |
|   3 |   4 | 2021-04-11 |   100 |
|   4 |   4 | 2021-04-11 |    99 |
|   5 |   2 | 2021-04-10 |    59 |
|   5 |   3 | 2021-04-12 |    94 |
|   5 |   4 | 2021-04-11 |    95 |
+-----+-----+------------+-------+
12 rows in set (0.00 sec)
```
## 参加了课程3的学生
```mysql
mysql> select a.* from student a inner join exame b on a.uid = b.uid where b.cid=3;
+-----+----------+-----+-----+
| uid | name     | age | sex |
+-----+----------+-----+-----+
|   2 | gaoyang  |  20 | W   |
|   3 | chenwei  |  22 | M   |
|   5 | liuxiang |  19 | W   |
+-----+----------+-----+-----+
```
## 没有参加课程3的学生
```mysql
mysql> select a.* from student a left join exame b on a.uid = b.uid and b.cid = 3 where b.uid is null;
+-----+----------+-----+-----+
| uid | name     | age | sex |
+-----+----------+-----+-----+
|   1 | zhangsan |  18 | M   |
|   4 | linfeng  |  21 | W   |
|   7 | weiwie   |  20 | M   |
+-----+----------+-----+-----+
```
## 内连接和外连接的不同分析
```mysql
mysql> select a.* from student a inner join exame b on a.uid = b.uid where b.cid=3;
+-----+----------+-----+-----+
| uid | name     | age | sex |
+-----+----------+-----+-----+
|   2 | gaoyang  |  20 | W   |
|   3 | chenwei  |  22 | M   |
|   5 | liuxiang |  19 | W   |
+-----+----------+-----+-----+
3 rows in set (0.00 sec)

mysql> select a.* from student a left join exame b on a.uid = b.uid where b.cid=3;
+-----+----------+-----+-----+
| uid | name     | age | sex |
+-----+----------+-----+-----+
|   2 | gaoyang  |  20 | W   |
|   3 | chenwei  |  22 | M   |
|   5 | liuxiang |  19 | W   |
+-----+----------+-----+-----+
3 rows in set (0.00 sec)

```
### 分析1
把b过滤后，使用b作为驱动表，然后a作为被驱动表
```mysql
mysql> explain select a.* from student a inner join exame b on a.uid = b.uid where b.cid=3 \G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: b
   partitions: NULL
         type: index
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 8
          ref: NULL
         rows: 12
     filtered: 10.00
        Extra: Using where; Using index
*************************** 2. row ***************************
           id: 1
  select_type: SIMPLE
        table: a
   partitions: NULL
         type: eq_ref
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 4
          ref: test.b.uid
         rows: 1
     filtered: 100.00
        Extra: NULL
```
### 分析2
```mysql
mysql>  select a.*,b.* from student a left join exame b on a.uid = b.uid  ;
+-----+----------+-----+-----+------+------+------------+-------+
| uid | name     | age | sex | uid  | cid  | time       | score |
+-----+----------+-----+-----+------+------+------------+-------+
|   1 | zhangsan |  18 | M   |    1 |    1 | 2021-04-09 |    99 |
|   1 | zhangsan |  18 | M   |    1 |    2 | 2021-04-10 |    90 |
|   2 | gaoyang  |  20 | W   |    2 |    2 | 2021-04-10 |    90 |
|   2 | gaoyang  |  20 | W   |    2 |    3 | 2021-04-12 |    85 |
|   3 | chenwei  |  22 | M   |    3 |    1 | 2021-04-09 |    56 |
|   3 | chenwei  |  22 | M   |    3 |    2 | 2021-04-10 |    93 |
|   3 | chenwei  |  22 | M   |    3 |    3 | 2021-04-12 |    89 |
|   3 | chenwei  |  22 | M   |    3 |    4 | 2021-04-11 |   100 |
|   4 | linfeng  |  21 | W   |    4 |    4 | 2021-04-11 |    99 |
|   5 | liuxiang |  19 | W   |    5 |    2 | 2021-04-10 |    59 |
|   5 | liuxiang |  19 | W   |    5 |    3 | 2021-04-12 |    94 |
|   5 | liuxiang |  19 | W   |    5 |    4 | 2021-04-11 |    95 |
|   7 | weiwie   |  20 | M   | NULL | NULL | NULL       |  NULL |
+-----+----------+-----+-----+------+------+------------+-------+
#再分析上面，其实如果不从优化器的角度来看的话，因为他带了cid = 3相当于cid is not null(空值拒绝--reject-NULL)，即可以把left join 转化为inner join了
mysql> explain  select a.*,b.* from student a left join exame b on a.uid = b.uid where cid=3 \G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: b
   partitions: NULL
         type: ALL
possible_keys: PRIMARY
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 12
     filtered: 10.00
        Extra: Using where
*************************** 2. row ***************************
           id: 1
  select_type: SIMPLE
        table: a
   partitions: NULL
         type: eq_ref
possible_keys: PRIMARY
          key: PRIMARY
      key_len: 4
          ref: test.b.uid
         rows: 1
     filtered: 100.00
        Extra: NULL
2 rows in set, 1 warning (0.00 sec)
#之所以b变成了驱动表，是因为sql语句被优化器优化了
mysql> show warnings \G
*************************** 1. row ***************************
  Level: Note
   Code: 1003
Message: /* select#1 */ select `test`.`a`.`uid` AS `uid`,`test`.`a`.`name` AS `name`,`test`.`a`.`age` AS `age`,`test`.`a`.`sex` AS `sex`,`test`.`b`.`uid` AS `uid`,`test`.`b`.`cid` AS `cid`,`test`.`b`.`time` AS `time`,`test`.`b`.`score` AS `score` from `test`.`student` `a` join `test`.`exame` `b` where ((`test`.`a`.`uid` = `test`.`b`.`uid`) and (`test`.`b`.`cid` = 3))
```
