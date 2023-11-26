#!/bin/bash


pid=$(ps -ef | grep -v 'grep' | egrep nginx| awk '{printf $2 " "}')
#echo "$pid"
if [ "$pid" != "" ]; then
    echo  "Shutting down openrestry/nginx:  pid is $pid"
     /usr/bin/su  - root  -c   "kill -s 9 $pid"
    echo  "Shutting down  succeeded!"
else
   echo "openrestry/nginx is not running!"
fi
