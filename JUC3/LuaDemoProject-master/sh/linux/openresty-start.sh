#!/bin/bash

# 设置 openresty 的安装目录
OPENRESTRY_PATH="/usr/local/openresty"

# 设置 Nginx 项目的工作目录
PROJECT_PATH="/vagrant/LuaDemoProject/src"

# 设置 项目的配置文件
# PROJECT_CONF="nginx-location-demo.conf"
# PROJECT_CONF="nginx.conf"
# PROJECT_CONF="nginx-ratelimit.conf"
# PROJECT_CONF="nginx-lua-demo.conf"
# PROJECT_CONF="nginx-seckill.conf"
# PROJECT_CONF="nginx-blog-demo.conf"
#PROJECT_CONF="nginx-seckill-sit.conf"
# PROJECT_CONF="nginx-simple.conf"
# PROJECT_CONF="nginx-redis-demo.conf"
# PROJECT_CONF="nginx-chang-content.conf"
# PROJECT_CONF="nginx-template-demo.conf"
PROJECT_CONF="nginx-proxy-demo.conf"

echo "OPENRESTRY_PATH:$OPENRESTRY_PATH"
echo "PROJECT_PATH:$PROJECT_PATH"

# 查找nginx所有的进程id
pid=$(ps -ef | grep -v 'grep' | egrep nginx| awk '{printf $2 " "}')
#echo "$pid"

if [ "$pid" != "" ]; then
   # 如果已经在执行，则提示
    echo "openrestry/nginx is started already, and pid is $pid, operating failed!"
else
   # 如果没有执行，则启动
    $OPENRESTRY_PATH/nginx/sbin/nginx  -p ${PROJECT_PATH}  -c ${PROJECT_PATH}/conf/${PROJECT_CONF}
    pid=$(ps -ef | grep -v 'grep' | egrep nginx| awk '{printf $2 " "}')
    echo "openrestry/nginx starting succeeded!"
    echo "pid is $pid "
fi
