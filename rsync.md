企业级数据同步解决方案
===============================

rsync + inotify
-------------------------------------

### 1、服务器
服务器  | IP  
----- | -----
vm01  | 192.144.1.4  
vm02  | 192.144.1.5

### 2、主服务器
新建SSL文件，只用保存密码
```
(echo -ne ;dd if=/dev/urandom bs=512 count=1 | openssl md5) > /opt/onframework/rsync311/config/SSL/rsyncd.key
```
新建推送脚本
```
vim rsync.sh
#!/bin/bash
src=/opt/onframework/htdocs/
des=htdocs
host=161.17.250.27
user=rsync
/opt/onframework/inotify314/bin/inotifywait -mrq --timefmt '%d/%m/%y %H:%M' --format '%T %w%f%e' -e modify,delete,create,attrib $src| while read files
do
    /opt/onframework/rsync311/bin/rsync -avz --delete --progress --password-file /opt/onframework/rsync311/config/SSL/rsyncd.key $src $user@$host::$des
    echo "${files} was rsynced" >>/opt/onframework/rsync311/logs/rsync.log 2>&1
done
```
也可以加入到开机自启动
```
echo "/opt/onframework/rsync311/shell/rsync.sh &" >> /etc/rc.local
```
*注意: 推送脚本应该在备份服务器同步脚本启动之后运行*

### 3、备份服务器
新建SSL文件，需要用户名和密码作为一组
```
(echo -ne "rsync:上面生成的密码" > /opt/onframework/rsync311/config/SSL/rsyncd.crt
```
新建配置文件
```
vim rsync.conf
# global parameters
motd file = /opt/onframework/rsync311/config/rsync.motd  #欢迎文件
pid file = /opt/onframework/rsync311/config/rsyncd.pid   #进程pid
port = 873  #传输端口
address = 161.17.250.27  #ip地址
[htdocs]  #模块
comment = rsync htdocs
path = /opt/onframework/htdocs/
read only = no
secrets file = /opt/onframework/rsync311/config/SSL/rsyncd.crt
auth users = rsync
use chroot = yes
uid = root
gid = root
hosts allow = 161.17.250.0/255.255.255.0
hosts deney = *
ignore errors
log file = /opt/onframework/rsync311/logs/rsync.log
```
运行备份进程
```
/opt/onframework/rsync311/bin/rsync --daemon --config=/opt/onframework/rsync311/config/rsync.conf
```