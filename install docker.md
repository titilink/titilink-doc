- 1、apt-get update
- 2、apt-get install apt-transport-https
- 3、apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
- 4、bash -c "echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
- 5、apt-get update
- 6、apt-get install lxc-docker
- 7、docker run ubuntu:14.04 /bin/echo 'Hello world' （启动一个容器->选择一个镜像->运行一个命令->命令参数）
- 8、docker run -t -i ubuntu:14.04 /bin/bash（相比上一个方法，以交互方式启动一个容器）
- 9、docker run -t -i -d --name hello-ubuntu ubuntu:14.04 /bin/bash -c "while true; do echo 'hello docker'; sleep 1; done"（后台方式运行一个docker容器，并执行一些命令，并且指定了容器id）


- push image到仓库：docker push 192.168.7.26:5000/test(仓库地址)
```	
搭建docker私仓：
	   容器方式搭建：docker run -d -p 5000:5000 -v /opt/data/registry:/tmp/registry registry
	   源码方式搭建： apt-get install build-essential python-dev libevent-dev python-pip libssl-dev liblzma-dev libffi-dev
	                  git clone https://github.com/docker/docker-registry.git
					  cd docker-registry
					  python setup.py install
					  cp config/config_sample.yml config/config.yml（修改 dev 模板段的 storage_path 到本地的存储仓库的路径）
					  gunicorn -c contrib/gunicorn.py docker_registry.wsgi:application（启动仓库）
```
