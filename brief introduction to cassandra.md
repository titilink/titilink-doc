### 目录
- 基础知识
- 数据模型
- 数据分布策略
- 存储机制
- 数据读写删
- 最终一致性
- Gossiper

### [参考链接]
- http://academy.datastax.com/demos/brief-introduction-apache-cassandra
- http://www.slideshare.net/mysqlops/no-sqlcassandra?next_slideshow=1
- http://www.slideshare.net/zhangzhaokun/cassandra-5106113

### 一、什么是NoSQL
NoSQL是伴随着大数据存储（PB级别）、读写低延迟（ms级别）、分布式、无单节点故障、快速故障恢复、持续运行、大规模、降低软件部署运维成本等等这些需求产生的。NoSQL采用了不同于传统关系型数据库的架构和数据模型。对于架构来说，要支持上述需求，必然采用分布式集群架构，但是分布式集群系统必然存在对[CAP](https://en.wikipedia.org/wiki/CAP_theorem)（Consistency、Availability、Partition tolerance）的权衡。NoSQL数据库在牺牲了一些关系型数据库的特性上（ACID、表关联），可以满足上述需求。

![image](http://code.huawei.com/cloud-service-dev-team-devops/console-framework/uploads/67bec3ad0979615242d408f51bdc330a/image.png)

CA：强调一致性和可用性，放弃分区（比如两阶段提交、关系数据库）

CP：强调一致性和分区容错，放弃可用性（比如Shard）， 一台Server宕机会导致系统不可用

AP：强调可用性和分区容错，放弃一致性，允许系统在返回不一致的数据，通过Eventually Consistent解决一致性

**NoSQL和关系型数据看对比表**

关系型数据库|NoSQL
-----------|-----
写入数据不能太频繁|支持频繁、持续的写入
只支持少量数据来源的写入|支持高并发写入
数据类型有限制|任何数据均可以
支持原子事务（内嵌事务）|支持简单事务
存在单节点故障|无单节点故障，可持续服务
表的列数目有限|支持几十亿（billion）的列
master-slave模式部署|去master部署，所有节点等同
数据一般写在一个节点|支持集群节点写入
支持规模化写入（要牺牲一致性）|支持规模化读取和写入
支持垂直扩容（scale up）|支持水平扩容（scale out）

### 二、Cassandra诞生
Cassandra was originally developed at Facebook, was open sourced in 2008, and became a top-level Apache project in 2010.

### 三、Cassandra特性
- Massively scalable architecture：去中心化架构，可以无缝的水平扩容
- Active everywhere design：所有节点等同，即可读取也能写入
- Linear scale performance：随着集群节点的增加，性能不会下降
- Continuous availability：支持数据和节点冗余，高可用
- Transparent fault detection and recovery：故障节点和自动检测并恢复
- Flexible and dynamic data model：灵活的数据模型或者说无模式设计
- Strong data protection：通过提交日志来保证数据（备份、恢复），但是相对于关系型数据库的redo、undo等数据保护措施，功能还是稍显薄弱
- Tunable data consistency：数据一致性可调（强一致性、弱一致性）
- Multi-data center replication：支持多数据中心复制
- Data compression：数据压缩
- CQL（Cassandra Query Language）：类SQL的数据库语言，迁移关系型数据库非常容易

### 四、最佳用例
- Internet of things applications：Cassandra生来就是支持海量数据存储、高并发写入，故对于互联网、移动互联网是再适合不过
- Product catalogs and retail apps
- User activity tracking and monitoring
- Messaging：消息存储
- Social media analytics and recommendation engines
- Other time-series-based applications：API网关数据最适合了

### 五、Cassandra数据模型
弄懂cassandra的数据模型，要搞清楚以下几个概念：

- Column：类SQL中的行，每个column是一个三元组tuple<name,value,timestamp>

采用类json表达方式是：
```
{"name":"username","value":"ganting","timestamp":"123120393"}
```

- SuperColumn：由多个Column组成的列簇，并且SuperColumn没有时间戳

采用类json表达方式是：
```
{
   "name":"author",
   "value":{
        "username":{"name":"username","value":"ganting","timestamp":"123120393"},
        "age":{"name":"age","value":"1","timestamp":"123120393"},
        "sex":{"name":"sex","value":"male","timestamp":"123120392"},
        "address":{"name":"address","value":"hangzhou","timestamp":"123120392"}
   }
}
```

- ColumnFamily：类SQL中的table，多个Row group成一个ColumnFamily，每个Row包含多个Column

数据存储的逻辑视图：

![image](http://code.huawei.com/cloud-service-dev-team-devops/console-framework/uploads/90c7373f6f38f985e028a9d58d2555f1/image.png)

映射成map格式：
```
Map<RowKey,SortedMap<ColumnKey,ColumnValue>>
```

采用类json表达方式：
```
{
   "ganting": {
        "username":{"name":"username","value":"ganting","timestamp":"123120393"},
        "age":{"name":"age","value":"1","timestamp":"123120393"},
        "sex":{"name":"sex","value":"male","timestamp":"123120392"},
        "address":{"name":"address","value":"hangzhou","timestamp":"123120392"}
   },
   "wangwu":{
        "username":{"name":"username","value":"wangwu","timestamp":"123120393"},
        "age":{"name":"age","value":"1","timestamp":"123120393"},
        "sex":{"name":"sex","value":"male","timestamp":"123120392"},
        "address":{"name":"address","value":"shenzhen","timestamp":"123120392"}
   }
}
```

- SuperColumnFamily：多个Row group成一个SuperColumnFamily，SuperColumnFamily只能包含SuperColumn

数据存储的逻辑视图：

![image](http://code.huawei.com/cloud-service-dev-team-devops/console-framework/uploads/d1749348f37e1ad6e7abeeb7f0735580/image.png)

映射成map格式：
```
Map<RowKey,SortedMap<SuperColumnKey,SortedMap<SubColumnKey,ColumnValue>>>
```

采用类json表达方式：
```
{
   "ganting":{
        "basicinfo": {
              "username":{"name":"username","value":"ganting","timestamp":"123120393"},
              "age":{"name":"age","value":"1","timestamp":"123120393"},
              "sex":{"name":"sex","value":"male","timestamp":"123120392"},
              "address":{"name":"address","value":"hangzhou","timestamp":"123120392"}
        },
        "followers":{
              "wangwu":{
                    "username":{"name":"username","value":"wangwu","timestamp":"123120393"},
                    "age":{"name":"age","value":"3","timestamp":"123120393"},
                    "sex":{"name":"sex","value":"male","timestamp":"123120392"},
                    "address":{"name":"address","value":"hangzhou","timestamp":"123120392"}
              },
              "lisi":{
                    "username":{"name":"username","value":"lisi","timestamp":"123120393"},
                    "age":{"name":"age","value":"3","timestamp":"123120393"},
                    "sex":{"name":"sex","value":"male","timestamp":"123120392"},
                    "address":{"name":"address","value":"hangzhou","timestamp":"123120392"}
              }
        }
   }
}
```

- Keyspace: 类SQL中的database，是ColumnFamily的容器，一般一个应用程序一个keysapce

- Row：一个Row以一个Key表示，一个Row对应的数据可以分布到不同的ColumnFamily，一般Cassandra是分布到一个ColumnFamily中

![image](http://code.huawei.com/cloud-service-dev-team-devops/console-framework/uploads/3cd1b263bab1b521a402311e43d18c66/image.png)


### 六、数据定位

- 第一层索引所用的 key 为 (row-key, cf-name)， 即用一个 row-key 和 column-family-name 可以定位一个 column family。column family 是 column 的集合。
- 第二层索引所用的 key 为 column-name， 即通过一个 column-name 可以在一个 column family 中定位一个 column。

### 七、cassandra数据分布策略

- 分布式hash table

![image](http://code.huawei.com/cloud-service-dev-team-devops/console-framework/uploads/21f928f00649019802f8432e2f2421bc/image.png)

![image](http://code.huawei.com/cloud-service-dev-team-devops/console-framework/uploads/bad4f649310fbdec9e55049f3f5379d2/image.png)

- 分区策略

 RandomPartitioner: 随机分区是一种hash分区策略，使用的Token是大整数型(BigInteger)，范围为0~2^127， Cassandra采用了MD5作为hash函数，其结果是128位的整数值

 OrderPreservingPartitioner：如果要支持针对Key的范围查询，那么可以选择这种有序分区策略。该策略采用的是字符串类型的Token。

 ByteOrderedPartitioner：和OrderPreservingPartitioner一样是有序分区策略。只是排序的方式不一样，采用的是字节型Token。

- 副本策略（keyspace级别的副本策略）

 LocalStrategy：只在本地节点中保持一个副本
 
 RackUnawareStrategy：不考虑机柜因素，将Token按照从小到大的顺序，从第一个Token位置处依次取N个节点作为副本。

 RackAwareStrategy：考虑机柜因素，在primaryToken之外，先找一个处于不同数据中心的点，然后在不同机柜找。

### 八、数据一致性（语句级别的数据一致性）

- 强一致性：数据在任何时刻、任意节点都是一样
- 弱一致性：有多种实现，比如：最终一致性、因果一致性等等

**Cassandra默认支持最终一致性：不保证在任意时刻任意节点上的同一份数据都是相同的，但是随着时间的迁移，不同节点上的同一份数据总是在向趋同的方向变化。**

- 读一致性：ONE、ALL、QuoRUM（nodesNum % 2 + 1）
- 写一致性：ONE、ALL、QuoRUM（nodesNum % 2 + 1）
- 删一致性：数据删除时不会立刻真正从物理磁盘上删除，而是写入一个墓碑值(tombstone)到该记录，宣告该条记录死刑，待到秋后（GC_Trace_Time）问斩删除。
