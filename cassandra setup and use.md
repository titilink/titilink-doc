安装Cassandra数据库
-----------------------
### 1、下载编译后的bin包
```
http://cassandra.apache.org/download/
选择稳定版2.1.8
```
### 2、解压bin包
```
tar zxvf apache-cassandra-2.1.8-bin.tar.gz
```
### 3、配置cassandra
```
vim conf/cassandra.yaml
   #集群名称
   cluster_name: 'Test Cluster'
   seed_provider:
    # Addresses of hosts that are deemed contact points. 
    # Cassandra nodes use this list of hosts to find each other and learn
    # the topology of the ring.  You must change this if you are running
    # multiple nodes!
    - class_name: org.apache.cassandra.locator.SimpleSeedProvider
      parameters:
          # seeds is actually a comma-delimited list of addresses.
          # Ex: "<ip1>,<ip2>,<ip3>"
          - seeds: "161.17.249.200"
    listen_address: 161.17.249.200
    rpc_address: 161.17.249.200
```
### 启动Cassandra
```
bin/cassandra
```
### 查看端口是否监听
```
lsof -i:9042
lsof -i:9160
```

使用Cassandra数据库
----------------------
### 1、进入cqlsh
```
bin/cqlsh 161.17.249.200 9042
如果出现下面语句表示成功进入cqlsh命令行
Connected to Test Cluster at 161.17.249.200:9042.
[cqlsh 5.0.1 | Cassandra 2.1.8 | CQL spec 3.2.0 | Native protocol v3]
Use HELP for help.
cqlsh>
```
### 2、新建keyspace
```
cqlsh> create keyspace if not exists apigateway with replication={'class':'SimpleStrategy','replication_factor' :1};
```
### 3、新建datamodel
```
cqlsh> use apigateway;
cqlsh> create table if not exists access_log  (
  id UUID,
  service_id varchar,
  uri varchar,
  version varchar,
  http_method varchar,
  start_time timestamp,
  end_time timestamp,
  user_id varchar,
  project_id varchar,
  domain_id varchar,
  PRIMARY KEY ((service_id,version,user_id), start_time)
)
WITH CLUSTERING ORDER BY (start_time DESC);
```
### 4、增删改查(CRUD)
```
cqlsh> select * from apigateway.access_log;
cqlsh> update apigateway.access_log set apigateway.service_id='vpc' where apigateway.service_id='ecs';
cqlsh> insert into apigateway.access_log(service_id,user_id,version) values('vpc', '123', 'v1.0');
cqlsh> delete from apigateway.access_log where apigateway.service_id='vpc';
```

**参考链接**
```
- http://cassandra.apache.org/download/
- http://cassandra.apache.org/doc/cql3/CQL.html#CQLSyntax
```
