#!/bin/bash


pid=$(ps -ef | grep -v 'grep' | egrep nginx| awk '{printf $2 " "}')
#echo "$pid"
if [ "$pid" != "" ]; then
    echo  "openrestry/nginx is running!"
    echo  "pid is $pid"
else
   echo "openrestry/nginx is not running!"
fi
