@echo off
tasklist|find /i "nginx.exe" > nul
if %errorlevel%==0 (
tasklist /fi "imagename eq nginx.exe"
echo "openresty/nginx is running!"
exit /b
) else echo "openresty/nginx is stoped!" 