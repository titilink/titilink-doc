企业级负载均衡解决方案
============================
nginx + healthchecker
----------------------------
### 1、前提条件
* 下载nginx源码
* 下载healthchecker第三方包

### 2、编译安装nginx

### 3、启动脚本
```
#!/bin/bash
######################################################################
#   DESCRIPTION: 切换到当前目录
#   CALLS      : 无
#   CALLED BY  : main
#   INPUT      : 无
#   OUTPUT     : 无
#   LOCAL VAR  : 无
#   USE GLOBVAR: 无
#   RETURN     : 无
#   CHANGE DIR : 无
######################################################################
getCurPath()
{
    # 1 如果当前目录就是install文件所在位置，直接pwd取得绝对路径
    # 2 而如果是从其他目录来调用install的情况，先cd到install文件所在目录,再取得install的绝对路径，并返回至原目录下
    # 3 使用install调用该文件，使用的是当前目录路径
    if [ "` dirname "$0" `" = "" ] || [ "` dirname "$0" `" = "." ] ; then
        CURRENT_PATH="`pwd`"
    else
        cd ` dirname "$0" `
        CURRENT_PATH="`pwd`"
        cd - > /dev/null 2>&1
    fi
}

. /etc/profile

##切换到当前路径
getCurPath
cd "${CURRENT_PATH}"

sh nginx_monitor.sh start
```
### 4、停止脚本
```
#!/bin/bash
######################################################################
#   DESCRIPTION: 切换到当前目录
#   CALLS      : 无
#   CALLED BY  : main
#   INPUT      : 无
#   OUTPUT     : 无
#   LOCAL VAR  : 无
#   USE GLOBVAR: 无
#   RETURN     : 无
#   CHANGE DIR : 无
######################################################################
getCurPath()
{
    # 1 如果当前目录就是install文件所在位置，直接pwd取得绝对路径
    # 2 而如果是从其他目录来调用install的情况，先cd到install文件所在目录,再取得install的绝对路径，并返回至原目录下
    # 3 使用install调用该文件，使用的是当前目录路径
    if [ "` dirname "$0" `" = "" ] || [ "` dirname "$0" `" = "." ] ; then
        CURRENT_PATH="`pwd`"
    else
        cd ` dirname "$0" `
        CURRENT_PATH="`pwd`"
        cd - > /dev/null 2>&1
    fi
}

. /etc/profile

##切换到当前路径
getCurPath
cd "${CURRENT_PATH}"

sh nginx_monitor.sh stop
```
### 5、监控脚本
```
#!/bin/bash
######################################################################
#   DESCRIPTION: 切换到当前目录
#   CALLS      : 无
#   CALLED BY  : main
#   INPUT      : 无
#   OUTPUT     : 无
#   LOCAL VAR  : 无
#   USE GLOBVAR: 无
#   RETURN     : 无
#   CHANGE DIR : 无
######################################################################
getCurPath()
{
    # 1 如果当前目录就是install文件所在位置，直接pwd取得绝对路径
    # 2 而如果是从其他目录来调用install的情况，先cd到install文件所在目录,再取得install的绝对路径，并返回至原目录下
    # 3 使用install调用该文件，使用的是当前目录路径
    if [ "` dirname "$0" `" = "" ] || [ "` dirname "$0" `" = "." ] ; then
        CURRENT_PATH="`pwd`"
    else
        cd ` dirname "$0" `
        CURRENT_PATH="`pwd`"
        cd - > /dev/null 2>&1
    fi
}

. /etc/profile

##切换到当前路径
getCurPath
cd "${CURRENT_PATH}"

#引入公共模块
. ./util.sh

#初始化
#执行日志目录初始化
initLogDir

##检查用户
chkUser

# action
ACTION=$1
shift

# init ret value for exit
RETVAL=0

# ensure action is specficed
[ -z "$ACTION" ] && die "no action is specficed"
logger_without_echo "Action is $ACTION"

# status
status()
{
    local pid=`ps -ww -eo pid,cmd | grep -w "nginx:" | grep -vwE "grep|vi|vim|tail|cat" | awk '{print $1}' | head -1`
    RETVAL=1
    [ -n "$pid" ] && RETVAL=0
    if [ "$RETVAL" -eq 0 ]; then
        # nginx is running
        logger "normal"
    else
        # nginx is not running
        logger "abnormal"
    fi
    return "$RETVAL"
}

# start
start()
{
    # do singleton protect
    if status >/dev/null ; then
        logger "process is running, no need to start"
        return ${RETURN_CODE_ERROR}
    fi

    RETVAL=0

    # start process
    expect -c "
        spawn /opt/onframework/nginx/sbin/nginx;
        expect {
                \"Enter PEM pass phrase:\"  {send \"$pass_new\r\"; exp_continue}
                \"Enter PEM pass phrase:\"  {send \"$pass_new\r\"; interact}
               }
        " > /dev/null 2>&1
    sleep 2;
    procnum=$(ps -wwef | grep "nginx: master" | grep -cv grep)
    if [ "$procnum" -ne "1" ]; then
        die "start fail"
    else
        logger "start success"
    fi

}

# stop
stop()
{
    # check if nginx start or not
    if status >/dev/null ; then
        logger "process is running, try to stop it"
    else
        logger "process is not running, no need to stop"
        return ${RETURN_CODE_ERROR}
    fi

    # stop process
    expect -c "
        spawn /opt/onframework/nginx/sbin/nginx -s stop;
        expect {
                \"Enter PEM pass phrase:\"  {send \"$pass_new\r\"; exp_continue}
                \"Enter PEM pass phrase:\"  {send \"$pass_new\r\"; interact}
               }
        " > /dev/null 2>&1

    sleep 2;
    procnum=$(ps -wwef | grep "nginx:" | grep -cv grep)
    if [ "$procnum" -ne "0" ]; then
        logger "nginx hasn't been stopped.";
        pid=$(ps -wwef | grep "nginx:" | grep -v grep | awk '{print $2}')
        kill -9 ${pid}
        logger "force to kill all processes."
    else
        logger "stop success"
    fi

}

# restart
restart()
{
    stop
    start
}

# reload
reload()
{
    # do singleton protect
    if status >/dev/null ; then
        expect -c "
            spawn /opt/onframework/nginx/sbin/nginx -s reload;
            expect {
                    \"Enter PEM pass phrase:\"  {send \"$pass_new\r\"; exp_continue}
                    \"Enter PEM pass phrase:\"  {send \"$pass_new\r\"; interact}
                   }
            " > /dev/null 2>&1
        if [ $? -eq 0 ] ; then
            logger "reload success"
        else
            die "reload fail"
        fi
    else
        logger "process is not running, can't reload."
    fi
}


case "$ACTION" in
    start)
    start
    ;;
    stop)
    stop
    ;;
    status)
    status
    ;;
    restart)
    restart
    ;;
    reload)
    reload
    ;;
    *)
    die $"Usage: $0 {start|stop|status|restart|reload}"
esac

exit $RETVAL
```
### 6、新建util脚本
```
#!/bin/bash
########################################################################
#
#   FUNCTION   : main
#   DESCRIPTION: copy dir to
#   CALLS      : 无
#   CALLED BY  : 无
#   INPUT      : 无
#   OUTPUT     : 无
#   LOCAL VAR  : 无
#   USE GLOBVAR: 无
#   RETURN     : 无
#   CHANGE DIR : 无
#######################################################################

#####################################################
# 用户相关变量
######################################################
SERVICE_USER=root
SERVICE_GROUP=onframework
MODULE_NAME=nginx

#####################################################
#
# 安装路径
#
#####################################################
PRODUCT_PATH=/opt/${SERVICE_USER}/${MODULE_NAME}
PRODUCT_BIN_DIR=${PRODUCT_PATH}/bin
PRODUCT_CONF_DIR=${PRODUCT_PATH}/config
PRODUCT_INSTALL_DIR=${PRODUCT_PATH}/install
PRODUCT_TOOL_DIR=${PRODUCT_PATH}/tool

#对应缺省：目录700 文件600权限
umask 0077

RETURN_CODE_SUCCESS=0
RETURN_CODE_ERROR=1

LOGMAXSIZE=5120
BASE_LOGGER_PATH=/var/log/console
##新建运行日志文件
LOGGER_PATH=${BASE_LOGGER_PATH}/monitor
LOGGER_FILE=${LOGGER_PATH}/${MODULE_NAME}.log

## 获取PEM强密码
pass=$(</opt/onframework/nginx/conf/SSL/key_pass)
pass_new=`sh /opt/onframework/nginx/tools/sec_tool.sh -k "$pass" | sed -n '/result:/p' | awk -F ':' '{print $2}'`

######################################################################
#  FUNCTION     : chkUser
#  DESCRIPTION  : 检查当前用户是否是$SERVICE_USER
#  CALLS        : 无
#  CALLED BY    : 任何需要调用此函数的地方
#  INPUT        : $1    想要检查的用户名
#  OUTPUT       : 无
#  READ GLOBVAR : 无
#  WRITE GLOBVAR: 无
#  RETURN       :   0   成功
#                   1   失败
######################################################################
chkUser()
{
    logger_without_echo "check current user"
    local curUser=$(/usr/bin/whoami | /usr/bin/awk '{print $1}')
    if [ "$curUser" = "$SERVICE_USER" ]; then
       logger_without_echo "check current user success"
       return 0
    else
       die "${MODULE_NAME} can only run by ${SERVICE_USER}"
    fi
}

######################################################################
#  FUNCTION     : initLogDir
#  DESCRIPTION  : 创建日志目录
#  CALLS        : 无
#  CALLED BY    : 本脚本初始化日志
#  INPUT        : 无
#  OUTPUT       : 无
#  READ GLOBVAR : 无
#  WRITE GLOBVAR: 无
#  RETURN       : 无
######################################################################
initLogDir()
{
    if [ -e "$LOGGER_PATH" ]; then
        return 0
    else
        mkdir -p ${LOGGER_PATH}
        chown onframework:onframework ${LOGGER_PATH}
        chmod 700 ${LOGGER_PATH}
        echo "init log dir success."
    fi
}


######################################################################
#  FUNCTION     : logger_without_echo
#  DESCRIPTION  : 记录日志到对应文件中，不输出到终端。
#  CALLS        : 无
#  CALLED BY    : 无
#  INPUT        : 无
#  OUTPUT       : 无
#  READ GLOBVAR : 无
#  WRITE GLOBVAR: 无
#  RETURN       : 无
######################################################################
logger_without_echo()
{
    local logsize=0
    if [ -e "$LOGGER_FILE" ]; then
        logsize=`ls -lk ${LOGGER_FILE} | awk -F " " '{print $5}'`
    else
        touch ${LOGGER_FILE}
        chown ${SERVICE_USER}: ${LOGGER_FILE}
        chmod 600 ${LOGGER_FILE}
    fi

    if [ "$logsize" -gt "$LOGMAXSIZE" ]; then
        # 每次删除10000行，约300K
        sed -i '1,10000d' "$LOGGER_FILE"
    fi
    echo "[` date -d today +\"%Y-%m-%d %H:%M:%S\"`,000] $*" >>"$LOGGER_FILE"

}
######################################################################
#  FUNCTION     : logger
#  DESCRIPTION  : 记录日志到对应文件中，同时输出到终端。
#  CALLS        : 无
#  CALLED BY    : 无
#  INPUT        : 无
#  OUTPUT       : 无
#  READ GLOBVAR : 无
#  WRITE GLOBVAR: 无
#  RETURN       : 无
######################################################################
logger()
{
    logger_without_echo $*
    echo "$*"
}

######################################################################
#  FUNCTION     : die
#  DESCRIPTION  : 记录日志并退出程序。
#  CALLS        : 无
#  CALLED BY    : 无
#  INPUT        : 无
#  OUTPUT       : 无
#  READ GLOBVAR : 无
#  WRITE GLOBVAR: 无
#  RETURN       : 无
######################################################################
die()
{
    logger "$*"
    exit ${RETURN_CODE_ERROR}
}
```
