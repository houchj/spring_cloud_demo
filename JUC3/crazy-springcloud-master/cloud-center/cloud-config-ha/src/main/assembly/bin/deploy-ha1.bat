echo off
title ConfigServerApplication
set SERVER_PORT=7788
set EUREKA_PORT=7777
set EUREKA_HOST=eureka-ha1
set JAR_NAME=config-ha-1.0-SNAPSHOT.jar
set MAIN_CLASS=com.crazymaker.cloud.center.config.ConfigServerApplication
set JVM= -server -Xms1g -Xmx1g


set APPLICATION_CONFIG=-Dserver.port=%SERVER_PORT% -Deureka.port=%EUREKA_PORT% -Deureka.host=%EUREKA_HOST%


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