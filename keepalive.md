企业级HA集群解决方案
===========================
keepalived + nginx
------------------------------
### 1、前提条件
* 已经安装nginx
* 已经安装keepalived
### 2、配置keepalived
```
vim keepalived.conf

! Configuration File for keepalived

global_defs {
   #notification_email {
     #monitor@3evip.cn
     #failover@firewall.loc
   #}
   #notification_email_from tianwei7518@163.com
   #smtp_server smtp.163.com
   #smtp_connect_timeout 30
   router_id LVS_DEVEL
}

vrrp_script chk_nginx {
   script "/etc/keepalived/chk_nginx.sh"
   interval 2
   weight 2
}

vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 100
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    track_script {
        chk_nginx
    }
    virtual_ipaddress {
        161.17.250.204/24
    }
}
```
### 3、配置nginx监控脚本
```
vim chk_nginx.sh

#!/bin/bash
status=`ps -C nginx --no-header | wc -l`
if [ ${status} -eq 0 ]; then
    su - onframework opt/onframework/nginx/bin/nginx_monitor.sh start
    status2=`ps -C nginx --no-header | wc -l`
    if [ ${status2} -eq 0 ]; then
        /opt/onframework/keepalived/sbin/keepalived stop
    fi
fi
```
### 4、运行nginx
### 5、运行keepalived
```
./keepalived -D -d -S 0 -f /opt/onframework/keepalived/config/keepalived.conf
```
### 6、keepalived原理
* 通过VRRP协议，主节点发送VRRP状态报文通知给备节点。
* 主节点异常，通过竞选方式，备节点接管VIP
* 主节点恢复，通过优先级判断是否抢回VIP