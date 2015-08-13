## 目录
- nginx的负载算法
- nginx的健康检查
- nginx的常用可靠性配置


### 1、nginx的负载算法
#### 1.1、轮询（默认） 
```
upstream backserver { 
    server 192.168.0.14; 
    server 192.168.0.15; 
} 
```
#### 1.2、指定权重（权重越大代表后端处理能力越强）
```
upstream backserver { 
    server 192.168.0.14 weight=10; 
    server 192.168.0.15 weight=7; 
} 
```
#### 1.3、IP绑定 ip_hash (每个请求按访问ip的hash结果分配，这样每个访客固定访问一个后端服务器)
```
upstream backserver { 
    ip_hash; 
    server 192.168.0.14:88; 
    server 192.168.0.15:80; 
} 
```
#### 1.4、fair（按后端服务器的响应时间来分配请求，响应时间短的优先分配）
**该插件需要额外安装**
```
upstream backserver { 
    server server1; 
    server server2; 
    fair; 
} 
```
#### 1.5、url_hash（按访问url的hash结果来分配请求，使每个url定向到同一个后端服务器，后端服务器为缓存时比较有效）
**该插件需要额外安装**
```
upstream backserver { 
    server squid1:3128; 
    server squid2:3128; 
    hash $request_uri; 
    hash_method crc32; 
} 
```

### 2、nginx的健康检查
#### 2.1、安装额外的第三方包nginx_upstream_check_module，console提供的包已经安装该模块
#### 2.2、配置健康检查
```
upstream nlbserver {
    server 10.180.45.227:8086;
    server 10.180.137.221:8086;
    check interval=2000 rise=1 fall=3 timeout=3000 type=tcp;
    # interval 检查的间隔时间
    # rise 检查成功几次，就将该后端服务加入集群服务
    # fall 检查失败几次，就将该后端服务剔除集群服务
    # timeout 检查请求的响应时间，超过该时间，表示后端服务检查失败
    # type后端服务采用tcp方式检查
}
```

### 3、nginx的常用可靠性配置
#### 3.1、server 127.0.0.1:9090 down; (down 表示当前的server暂时不参与负载) 
#### 3.2、server 127.0.0.1:7070 backup; (其它所有的非backup机器down或者忙的时候，请求backup机器) 
