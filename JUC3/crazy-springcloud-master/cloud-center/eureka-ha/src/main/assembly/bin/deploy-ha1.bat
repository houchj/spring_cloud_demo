echo off
title EurekaServerApplication

REM set SERVER_PORT=7777
set JAR_NAME=eureka-ha-1.0-SNAPSHOT.jar
set MAIN_CLASS=com.crazymaker.springcloud.cloud.center.eureka.EurekaServerApplication
REM set JVM= -server -Xms1g -Xmx1g
set JVM= -server -Xms64m -Xmx256m
set NACOS_ADDR="127.0.0.1:8848"

set APPLICATION_CONFIG=-Dspring.profiles.active=ha1 -Dspring.cloud.nacos.discovery.server-addr=%NACOS_ADDR% -Dspring.cloud.nacos.config.server-addr=%NACOS_ADDR%


set DEBUG_OPTS=
if ""%1"" == ""debug"" (
   set DEBUG_OPTS= -Xdebug -Xrunjdwp:transport=dt_socket,address=5005,server=y,suspend=n
   goto debug
)

echo "Starting the %JAR_NAME%"
java %JVM% %APPLICATION_CONFIG%  -jar ../lib/%JAR_NAME% %MAIN_CLASS%
goto end

:debug
echo "start debug mode ......"
java %JVM% %APPLICATION_CONFIG%  %DEBUG_OPTS%  -jar ../lib/%JAR_NAME% %MAIN_CLASS%
goto end

:end
pause