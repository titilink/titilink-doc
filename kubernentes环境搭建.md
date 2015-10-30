[参考链接](http://blog.csdn.net/qingchi0/article/details/42538549)

- 物料
```
1、四台云主机（1台master节点、1台etcd节点、2台minons节点），当然master和etcd也可以集群部署
2、网络打通
```
IP|角色
---|---
192.168.0.104|kubernetes master
192.168.0.109|etcd
192.168.0.110|kubernetes minon1
192.168.0.108|kubernetes minon2

- 安装
```
1、安装master
    wget https://github.com/GoogleCloudPlatform/kubernetes/releases/download/v0.8.0/kubernetes.tar.gz
    tar -zxvf kubernetes.tar.gz
    cd kubernetes/server/kubernetes
    tar -zxvf kubernetes-server-linux-amd64.tar.gz
    cd server/bin
    将kube-apiserver、kube-controller-manager、kube-scheduler、kubecfg、kubectl拷贝到/bin
2、安装etcd
    curl -L  https://github.com/coreos/etcd/releases/download/v2.0.0-rc.1/etcd-v2.0.0-rc.1-linux-amd64.tar.gz -o etcd-v2.0.0-rc.1-linux-amd64.tar.gz
    tar zxvf etcd-v2.0.0-rc.1-linux-amd64.tar.gz
    cd etcd-v2.0.0-rc.1-linux-amd64
    cp etcd的可执行文件到/bin/目录下
3、安装minion
    - 安装docker
    - 拷贝master节点的kube-proxy和kubelet到minion节点，并拷贝到/bin目录
    - 安装cadvisor
         wget https://github.com/google/cadvisor/releases/download/0.7.1/cadvisor
         直接拷贝到/bin目录
```
