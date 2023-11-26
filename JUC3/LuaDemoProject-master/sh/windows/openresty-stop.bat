@echo off
tasklist|find /i "nginx.exe"  > nul
if  %errorlevel%==0 (
    taskkill /f /t /im nginx.exe > nul
    echo "openresty/nginx stoped!"
)else echo "openresty/nginx not running!"
